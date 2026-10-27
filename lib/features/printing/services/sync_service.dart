import 'dart:async';
import 'package:dio/dio.dart';
import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';

/// Single-flight background synchronization worker for orders and hybrid print jobs.
/// Dispatches unsynced records oldest-first to `POST /orders/sync` with `Idempotency-Key`.
class SyncService {
  SyncService({
    required this.repository,
    required this.apiClient,
    this.periodicInterval = const Duration(seconds: 30),
  });

  final LocalOrderRepository repository;
  final ApiClient apiClient;
  final Duration periodicInterval;
  LocalOrderRepository get _repository => repository;
  ApiClient get _apiClient => apiClient;
  Duration get _periodicInterval => periodicInterval;

  bool _isSyncing = false;
  int _backoffSeconds = 2;
  Timer? _periodicTimer;
  Timer? _retryTimer;

  bool get isSyncing => _isSyncing;

  /// Starts the 30-second recurring sync timer and triggers initial sync.
  void start() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_periodicInterval, (_) {
      triggerSync();
    });
    triggerSync();
  }

  /// Triggers a synchronization pass.
  /// Single-flight drain: ignores calls if a sync pass is already running.
  Future<void> triggerSync() async {
    if (_isSyncing) {
      LoggerService.debug('SyncService: Pass already running. Skipping trigger.');
      return;
    }

    _isSyncing = true;
    _retryTimer?.cancel();

    try {
      final unsynced = _repository.unsyncedOldestFirst();
      if (unsynced.isEmpty) {
        _isSyncing = false;
        return;
      }

      LoggerService.info('SyncService: Starting sync drain for ${unsynced.length} records.');

      for (final record in unsynced) {
        final sentRev = record.rev;
        final stopwatch = Stopwatch()..start();

        try {
          final response = await _apiClient.post<Map<String, dynamic>>(
            ApiEndpoints.ordersSync,
            data: record.toJson(),
            options: Options(
              headers: {
                'Idempotency-Key': record.orderId,
              },
            ),
          );

          stopwatch.stop();

          final body = response.data ?? <String, dynamic>{};
          final data = (body['data'] as Map<String, dynamic>?) ?? body;

          final serverOrderId = data['serverOrderId'] as String? ??
              data['id'] as String? ??
              'srv_${record.orderId}';
          final finalOrderNo = data['finalOrderNo'] as String? ??
              data['localNo'] as String?;
          final serverJobs = (data['jobs'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList();

          final confirmed = await _repository.markSynced(
            record.orderId,
            sentRev,
            serverOrderId,
            finalOrderNo: finalOrderNo,
            serverJobs: serverJobs,
          );

          LoggerService.info(
            'SYNC SUCCESS [orderId: ${record.orderId}, sentRev: $sentRev, '
            'confirmed: $confirmed, serverOrderId: $serverOrderId, duration: ${stopwatch.elapsedMilliseconds}ms]',
          );

          // Reset backoff on success
          _backoffSeconds = 2;
        } on DioException catch (dioErr) {
          stopwatch.stop();
          final statusCode = dioErr.response?.statusCode ?? 0;
          final errorMsg = dioErr.message ?? dioErr.toString();

          // Network error, timeout, 5xx, 408, 429 -> stop and exponential backoff
          if (_isRetriableNetworkError(dioErr, statusCode)) {
            LoggerService.warning(
              'SYNC RETRIABLE ERROR [orderId: ${record.orderId}, status: $statusCode]: $errorMsg. '
              'Backing off for ${_backoffSeconds}s.',
            );

            _scheduleBackoffRetry();
            break; // Stop processing queue
          } else {
            // Other 4xx error (e.g. 400 Bad Request, 422 Unprocessable) -> mark error and proceed to next record
            LoggerService.error(
              'SYNC 4XX CLIENT ERROR [orderId: ${record.orderId}, status: $statusCode]: $errorMsg',
            );

            await _repository.markSyncError(
              record.orderId,
              'HTTP $statusCode: $errorMsg',
            );
            // Continue with next record
          }
        } catch (e) {
          stopwatch.stop();
          LoggerService.error('SYNC UNEXPECTED ERROR [orderId: ${record.orderId}]: $e');
          _scheduleBackoffRetry();
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  bool _isRetriableNetworkError(DioException err, int statusCode) {
    if (statusCode >= 500 || statusCode == 408 || statusCode == 429) {
      return true;
    }
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return true;
    }
    return false;
  }

  void _scheduleBackoffRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _backoffSeconds), () {
      triggerSync();
    });

    // Exponential backoff: 2s -> 4s -> 8s -> 16s -> 32s -> 60s max
    _backoffSeconds = (_backoffSeconds * 2).clamp(2, 60);
  }

  void dispose() {
    _periodicTimer?.cancel();
    _retryTimer?.cancel();
  }
}

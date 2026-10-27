import 'dart:convert';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/features/printing/models/order_record.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistent repository for [OrderRecord]s using [SharedPreferences].
/// Provides atomic persistence, revision tracking, safe status updates,
/// and stale revision guards on sync confirmation.
class LocalOrderRepository {
  LocalOrderRepository({required this.prefs});

  final SharedPreferences prefs;
  SharedPreferences get _prefs => prefs;

  static const String _indexKey = 'neram_orders_index_v1';
  static const String _orderPrefix = 'neram_order_rec_';

  List<String> _getOrderIds() {
    return _prefs.getStringList(_indexKey) ?? <String>[];
  }

  Future<void> _saveOrderIds(List<String> ids) async {
    await _prefs.setStringList(_indexKey, ids);
  }

  /// Atomically saves an [OrderRecord] to local storage.
  /// If [orderId] is not yet indexed, adds it to the index.
  Future<void> save(OrderRecord record) async {
    final rawJson = jsonEncode(record.toJson());
    await _prefs.setString('$_orderPrefix${record.orderId}', rawJson);

    final ids = _getOrderIds();
    if (!ids.contains(record.orderId)) {
      ids.add(record.orderId);
      await _saveOrderIds(ids);
    }
  }

  /// Checks if an order with [orderId] already exists locally.
  bool exists(String orderId) {
    return _prefs.containsKey('$_orderPrefix$orderId');
  }

  /// Retrieves an [OrderRecord] by its [orderId], or `null` if not found.
  OrderRecord? get(String orderId) {
    final raw = _prefs.getString('$_orderPrefix$orderId');
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return OrderRecord.fromJson(json);
    } catch (e) {
      LoggerService.error('Failed to decode OrderRecord for $orderId: $e');
      return null;
    }
  }

  /// Finds a job by [jobId] across all local order records.
  ({OrderRecord record, PrintJob job})? getJob(String jobId) {
    for (final orderId in _getOrderIds()) {
      final record = get(orderId);
      if (record == null) continue;
      for (final job in record.jobs) {
        if (job.jobId == jobId) {
          return (record: record, job: job);
        }
      }
    }
    return null;
  }

  /// Updates the status of a specific job within an order record.
  /// Increments `rev` and saves atomically.
  Future<OrderRecord?> setStatus(
    String orderId,
    String jobId,
    PrintStatus newStatus,
  ) async {
    final record = get(orderId);
    if (record == null) return null;

    final updatedJobs = record.jobs.map((job) {
      if (job.jobId != jobId) return job;

      // Duplicate guard: Never downgrade a terminal status (printed / serverPrinted)
      if (job.status.isFinalSuccess && !newStatus.isFinalSuccess) {
        return job;
      }

      return job.copyWith(
        status: newStatus,
        updatedAt: DateTime.now().toUtc(),
      );
    }).toList();

    final updatedRecord = record.copyWith(
      jobs: updatedJobs,
      autoIncrementRev: true,
    );

    await save(updatedRecord);
    return updatedRecord;
  }

  /// Updates the attempt count and error message of a job.
  /// If [newStatus] is provided, updates status as well.
  Future<OrderRecord?> setError(
    String orderId,
    String jobId,
    String error, {
    PrintStatus? newStatus,
  }) async {
    final record = get(orderId);
    if (record == null) return null;

    final updatedJobs = record.jobs.map((job) {
      if (job.jobId != jobId) return job;

      return job.copyWith(
        attempts: job.attempts + 1,
        lastError: error,
        status: newStatus ?? job.status,
        updatedAt: DateTime.now().toUtc(),
      );
    }).toList();

    final updatedRecord = record.copyWith(
      jobs: updatedJobs,
      autoIncrementRev: true,
    );

    await save(updatedRecord);
    return updatedRecord;
  }

  /// Confirms backend sync for an order record.
  ///
  /// STRICT RULE: Only sets `synced = true` if the current `record.rev == sentRev`.
  /// If the record was modified locally while the sync request was in-flight
  /// (`rev > sentRev`), `synced` remains `false` so the next sync worker iteration
  /// will dispatch the latest revision.
  Future<bool> markSynced(
    String orderId,
    int sentRev,
    String serverOrderId, {
    String? finalOrderNo,
    List<Map<String, dynamic>>? serverJobs,
  }) async {
    final record = get(orderId);
    if (record == null) return false;

    // Merge server job statuses into the local record without lowering a final status
    var currentJobs = record.jobs;
    if (serverJobs != null && serverJobs.isNotEmpty) {
      currentJobs = currentJobs.map((localJob) {
        final serverJob = serverJobs.firstWhere(
          (sj) => sj['jobId'] == localJob.jobId,
          orElse: () => const <String, dynamic>{},
        );

        if (serverJob.isEmpty || !serverJob.containsKey('status')) {
          return localJob;
        }

        final serverStatus = PrintStatus.fromString(
          serverJob['status'] as String? ?? '',
        );

        // Never overwrite a printed status with a lower or pending status
        if (localJob.status.isFinalSuccess && !serverStatus.isFinalSuccess) {
          return localJob;
        }

        return localJob.copyWith(
          status: serverStatus,
          updatedAt: DateTime.now().toUtc(),
        );
      }).toList();
    }

    final isSameRev = record.rev == sentRev;

    final updatedRecord = record.copyWith(
      serverOrderId: serverOrderId,
      localNo: finalOrderNo ?? record.localNo,
      jobs: currentJobs,
      synced: isSameRev ? true : record.synced,
      lastSyncError: null,
      autoIncrementRev: false, // Preserves rev identity for sync confirmation
    );

    await save(updatedRecord);
    return isSameRev;
  }

  /// Records a synchronization error for an order.
  Future<void> markSyncError(String orderId, String error) async {
    final record = get(orderId);
    if (record == null) return;

    final updatedRecord = record.copyWith(
      lastSyncError: error,
      autoIncrementRev: false,
    );

    await save(updatedRecord);
  }

  /// Returns all unsynced records (`synced == false`), ordered oldest first.
  List<OrderRecord> unsyncedOldestFirst() {
    final all = <OrderRecord>[];
    for (final id in _getOrderIds()) {
      final rec = get(id);
      if (rec != null && !rec.synced) {
        all.add(rec);
      }
    }
    all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return all;
  }

  /// Returns all stored order records.
  List<OrderRecord> allRecords() {
    final all = <OrderRecord>[];
    for (final id in _getOrderIds()) {
      final rec = get(id);
      if (rec != null) {
        all.add(rec);
      }
    }
    return all;
  }

  /// Returns all jobs across all stored order records.
  List<PrintJob> allJobs() {
    final jobs = <PrintJob>[];
    for (final rec in allRecords()) {
      jobs.addAll(rec.jobs);
    }
    return jobs;
  }

  /// Clears all local records (used for test setup/teardown).
  Future<void> clearAll() async {
    for (final id in _getOrderIds()) {
      await _prefs.remove('$_orderPrefix$id');
    }
    await _prefs.remove(_indexKey);
  }
}

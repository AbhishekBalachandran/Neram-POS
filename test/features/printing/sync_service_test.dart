import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/features/printing/models/order_record.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:neram_pos/features/printing/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient implements ApiClient {
  MockApiClient({
    this.throw500 = false,
    this.throw400 = false,
  });

  bool throw500;
  bool throw400;
  int postCallCount = 0;
  final List<String> idempotencyKeys = [];

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    postCallCount++;
    final key = options?.headers?['Idempotency-Key'] as String?;
    if (key != null) idempotencyKeys.add(key);

    if (throw500) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 500,
          statusMessage: 'Internal Server Error',
        ),
        type: DioExceptionType.badResponse,
      );
    }

    if (throw400) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 400,
          statusMessage: 'Bad Request',
        ),
        type: DioExceptionType.badResponse,
      );
    }

    final recordMap = data as Map<String, dynamic>;
    final orderId = recordMap['orderId'] as String;

    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'success': true,
        'data': {
          'serverOrderId': 'srv_$orderId',
          'finalOrderNo': recordMap['localNo'],
          'jobs': [
            {
              'jobId': 'job-1',
              'status': 'printed',
            }
          ]
        }
      } as T,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalOrderRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = LocalOrderRepository(prefs: prefs);
  });

  OrderRecord createTestRecord({
    required String orderId,
    required DateTime createdAt,
  }) {
    return OrderRecord(
      orderId: orderId,
      localNo: '#ORD-$orderId',
      payload: {},
      jobs: [
        PrintJob(
          jobId: 'job-1',
          printerId: 'prn-1',
          type: 'kitchen_kot',
          ticketData: '',
          status: PrintStatus.printed,
        ),
      ],
      synced: false,
      rev: 1,
      createdAt: createdAt,
    );
  }

  group('SyncService Tests', () {
    test('successful sync marks order synced and passes Idempotency-Key', () async {
      final mockApi = MockApiClient();
      final syncService = SyncService(
        repository: repository,
        apiClient: mockApi,
      );

      final record = createTestRecord(
        orderId: 'ord-sync-1',
        createdAt: DateTime.now().toUtc(),
      );
      await repository.save(record);

      await syncService.triggerSync();

      expect(mockApi.postCallCount, equals(1));
      expect(mockApi.idempotencyKeys.first, equals('ord-sync-1'));

      final syncedRecord = repository.get('ord-sync-1');
      expect(syncedRecord!.synced, isTrue);
      expect(syncedRecord.serverOrderId, equals('srv_ord-sync-1'));
    });

    test('500 server error stops queue drain and preserves unsynced status', () async {
      final mockApi = MockApiClient(throw500: true);
      final syncService = SyncService(
        repository: repository,
        apiClient: mockApi,
      );

      final rec1 = createTestRecord(
        orderId: 'ord-1',
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
      );
      final rec2 = createTestRecord(
        orderId: 'ord-2',
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      await repository.save(rec1);
      await repository.save(rec2);

      await syncService.triggerSync();

      // Because rec1 encountered 500, queue stops immediately
      expect(mockApi.postCallCount, equals(1));
      expect(repository.get('ord-1')!.synced, isFalse);
      expect(repository.get('ord-2')!.synced, isFalse);
    });

    test('400 client error marks sync error on current record and continues to next', () async {
      final mockApi = MockApiClient(throw400: true);
      final syncService = SyncService(
        repository: repository,
        apiClient: mockApi,
      );

      final rec1 = createTestRecord(
        orderId: 'ord-1',
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
      );
      final rec2 = createTestRecord(
        orderId: 'ord-2',
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      await repository.save(rec1);
      await repository.save(rec2);

      await syncService.triggerSync();

      // On 4xx, records error and moves to next record
      expect(mockApi.postCallCount, equals(2));
      expect(repository.get('ord-1')!.lastSyncError, contains('400'));
      expect(repository.get('ord-2')!.lastSyncError, contains('400'));
    });
  });
}


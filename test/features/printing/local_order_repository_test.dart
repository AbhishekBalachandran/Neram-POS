import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/features/printing/models/order_record.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalOrderRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = LocalOrderRepository(prefs: prefs);
  });

  OrderRecord createSampleRecord({
    String orderId = 'ord-101',
    String localNo = '#ORD-1',
    DateTime? createdAt,
    int rev = 1,
  }) {
    return OrderRecord(
      orderId: orderId,
      localNo: localNo,
      payload: {'table': 'T-01', 'total': 25.0},
      jobs: [
        PrintJob(
          jobId: 'job-1',
          printerId: 'prn-1',
          type: 'kitchen_kot',
          ticketData: 'RAW_TICKET_DATA',
          status: PrintStatus.pending,
        ),
      ],
      synced: false,
      rev: rev,
      createdAt: createdAt ?? DateTime.now().toUtc(),
    );
  }

  group('LocalOrderRepository Tests', () {
    test('saves and retrieves order record correctly', () async {
      final record = createSampleRecord();
      await repository.save(record);

      expect(repository.exists(record.orderId), isTrue);
      final retrieved = repository.get(record.orderId);
      expect(retrieved, isNotNull);
      expect(retrieved!.orderId, equals(record.orderId));
      expect(retrieved.localNo, equals(record.localNo));
      expect(retrieved.jobs.length, equals(1));
      expect(retrieved.jobs.first.status, equals(PrintStatus.pending));
    });

    test('setStatus updates job status and increments revision', () async {
      final record = createSampleRecord(rev: 1);
      await repository.save(record);

      final updated = await repository.setStatus(
        record.orderId,
        'job-1',
        PrintStatus.printed,
      );

      expect(updated, isNotNull);
      expect(updated!.rev, equals(2));
      expect(updated.jobs.first.status, equals(PrintStatus.printed));

      // Attempting to downgrade a printed status is ignored
      final attemptDowngrade = await repository.setStatus(
        record.orderId,
        'job-1',
        PrintStatus.pending,
      );
      expect(attemptDowngrade!.jobs.first.status, equals(PrintStatus.printed));
    });

    test('setError records error, increments attempt count and revision', () async {
      final record = createSampleRecord(rev: 1);
      await repository.save(record);

      final updated = await repository.setError(
        record.orderId,
        'job-1',
        'Connection refused to 192.168.1.100:9100',
        newStatus: PrintStatus.failed,
      );

      expect(updated, isNotNull);
      expect(updated!.rev, equals(2));
      expect(updated.jobs.first.attempts, equals(1));
      expect(
        updated.jobs.first.lastError,
        contains('Connection refused'),
      );
      expect(updated.jobs.first.status, equals(PrintStatus.failed));
    });

    test('markSynced marks synced true if rev matches sentRev', () async {
      final record = createSampleRecord(rev: 2);
      await repository.save(record);

      final success = await repository.markSynced(
        record.orderId,
        2, // sentRev matches current rev
        'srv-999',
        finalOrderNo: '#ORD-FINAL-1',
      );

      expect(success, isTrue);
      final retrieved = repository.get(record.orderId);
      expect(retrieved!.synced, isTrue);
      expect(retrieved.serverOrderId, equals('srv-999'));
      expect(retrieved.localNo, equals('#ORD-FINAL-1'));
    });

    test('markSynced keeps synced false if local rev has changed (stale rev guard)', () async {
      final record = createSampleRecord(rev: 2);
      await repository.save(record);

      // Local record was modified in the meantime, rev is now 3
      await repository.setStatus(record.orderId, 'job-1', PrintStatus.printing);
      final current = repository.get(record.orderId);
      expect(current!.rev, equals(3));

      // Server returns confirmation for older sentRev = 2
      final success = await repository.markSynced(
        record.orderId,
        2, // Stale revision
        'srv-999',
      );

      expect(success, isFalse);
      final afterSync = repository.get(record.orderId);
      // synced remains false so next sync cycle sends revision 3
      expect(afterSync!.synced, isFalse);
      expect(afterSync.serverOrderId, equals('srv-999'));
    });

    test('unsyncedOldestFirst orders records oldest first', () async {
      final now = DateTime.now().toUtc();
      final rec1 = createSampleRecord(
        orderId: 'ord-1',
        createdAt: now.subtract(const Duration(minutes: 5)),
      );
      final rec2 = createSampleRecord(
        orderId: 'ord-2',
        createdAt: now.subtract(const Duration(minutes: 10)),
      );
      final rec3 = createSampleRecord(
        orderId: 'ord-3',
        createdAt: now.subtract(const Duration(minutes: 1)),
      );

      await repository.save(rec1);
      await repository.save(rec2);
      await repository.save(rec3);

      final unsynced = repository.unsyncedOldestFirst();
      expect(unsynced.length, equals(3));
      expect(unsynced[0].orderId, equals('ord-2')); // oldest (10 min ago)
      expect(unsynced[1].orderId, equals('ord-1')); // (5 min ago)
      expect(unsynced[2].orderId, equals('ord-3')); // newest (1 min ago)
    });
  });
}


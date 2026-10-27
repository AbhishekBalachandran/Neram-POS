import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/features/printing/models/order_record.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/models/printer_config.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:neram_pos/features/printing/services/print_queue.dart';
import 'package:neram_pos/features/printing/services/printer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPrinterService implements PrinterService {
  MockPrinterService({this.shouldFail = false, this.failAttemptsCount = 0});

  final bool shouldFail;
  final int failAttemptsCount;
  int attempts = 0;
  final List<String> printedPrinters = [];

  @override
  Future<void> printRaw(
    String ip,
    int port,
    List<int> bytes, {
    Duration connectTimeout = const Duration(seconds: 3),
    Duration overallTimeout = const Duration(seconds: 5),
  }) async {
    attempts++;
    if (shouldFail) {
      throw const PrinterConnectionRefusedException('Connection refused');
    }
    if (attempts <= failAttemptsCount) {
      throw const PrinterTimeoutException('Timed out');
    }
    printedPrinters.add('$ip:$port');
  }
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

  const testPrinter = PrinterConfig(
    id: 'prn-kitchen',
    name: 'Kitchen Printer',
    ip: '192.168.1.100',
    port: 9100,
    role: 'kitchen',
  );

  OrderRecord createTestRecord({
    String orderId = 'ord-101',
    PrintStatus jobStatus = PrintStatus.pending,
  }) {
    return OrderRecord(
      orderId: orderId,
      localNo: '#ORD-1',
      payload: {},
      jobs: [
        PrintJob(
          jobId: 'job-1',
          printerId: 'prn-kitchen',
          type: 'kitchen_kot',
          ticketData: 'TICKET_BYTES',
          status: jobStatus,
        ),
      ],
      synced: false,
      rev: 1,
    );
  }

  group('PrintQueue Tests', () {
    test('successful print updates job status to printed', () async {
      final mockPrinter = MockPrinterService();
      var completedTriggered = false;

      final queue = PrintQueue(
        repository: repository,
        printerService: mockPrinter,
        onJobCompleted: () {
          completedTriggered = true;
        },
      );

      final record = createTestRecord();
      await repository.save(record);

      queue.enqueue(
        orderId: record.orderId,
        job: record.jobs.first,
        printer: testPrinter,
        rawTicketBytes: [1, 2, 3],
      );

      await queue.drainAll();

      final updated = repository.get(record.orderId);
      expect(updated!.jobs.first.status, equals(PrintStatus.printed));
      expect(mockPrinter.attempts, equals(1));
      expect(completedTriggered, isTrue);
    });

    test('retries 3 times on failure then sets fallbackRequested and notifies UI', () async {
      final mockPrinter = MockPrinterService(shouldFail: true);
      String? fallbackOrderId;
      PrintJob? fallbackJob;

      final queue = PrintQueue(
        repository: repository,
        printerService: mockPrinter,
        onPrintFallback: (orderId, job, error) {
          fallbackOrderId = orderId;
          fallbackJob = job;
        },
      );

      final record = createTestRecord();
      await repository.save(record);

      queue.enqueue(
        orderId: record.orderId,
        job: record.jobs.first,
        printer: testPrinter,
        rawTicketBytes: [1, 2, 3],
      );

      await queue.drainAll();

      final updated = repository.get(record.orderId);
      expect(mockPrinter.attempts, equals(3)); // 3 attempts made
      expect(updated!.jobs.first.status, equals(PrintStatus.fallbackRequested));
      expect(fallbackOrderId, equals(record.orderId));
      expect(fallbackJob?.status, equals(PrintStatus.fallbackRequested));
    });

    test('duplicate guard skips already printed or fallbackRequested jobs', () async {
      final mockPrinter = MockPrinterService();

      final queue = PrintQueue(
        repository: repository,
        printerService: mockPrinter,
      );

      final record = createTestRecord(jobStatus: PrintStatus.printed);
      await repository.save(record);

      queue.enqueue(
        orderId: record.orderId,
        job: record.jobs.first,
        printer: testPrinter,
        rawTicketBytes: [1, 2, 3],
      );

      await queue.drainAll();

      // No socket call should be made
      expect(mockPrinter.attempts, equals(0));
    });
  });
}


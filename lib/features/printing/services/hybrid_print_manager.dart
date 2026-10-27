import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/features/printing/models/order_record.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/models/printer_config.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:neram_pos/features/printing/services/print_queue.dart';
import 'package:neram_pos/features/printing/services/printer_config_service.dart';
import 'package:neram_pos/features/printing/services/printer_service.dart';
import 'package:neram_pos/features/printing/services/sync_service.dart';
import 'package:neram_pos/features/printing/services/ticket_builder.dart';
import 'package:neram_pos/features/printing/utils/uuid_generator.dart';

/// Top-level coordinator managing local persistence, LAN thermal printing,
/// background server synchronization, and manual recovery UI.
class HybridPrintManager extends ChangeNotifier {
  HybridPrintManager({
    required LocalOrderRepository repository,
    required PrinterService printerService,
    required this.printerConfigService,
    required this.syncService,
  })  : _repository = repository {
    _printQueue = PrintQueue(
      repository: repository,
      printerService: printerService,
      onJobCompleted: () {
        syncService.triggerSync();
        notifyListeners();
      },
      onPrintFallback: (orderId, job, error) {
        notifyListeners();
      },
    );
  }

  final LocalOrderRepository _repository;
  final PrinterConfigService printerConfigService;
  final SyncService syncService;
  late final PrintQueue _printQueue;

  PrinterConfigService get _printerConfigService => printerConfigService;
  SyncService get _syncService => syncService;

  bool _isSendInProgress = false;

  bool get isSendInProgress => _isSendInProgress;
  int get unsyncedOrdersCount => _repository.unsyncedOldestFirst().length;
  List<PrinterConfig> get configuredPrinters => _printerConfigService.printers;

  /// Returns all jobs across local records that require attention (failed, fallbackRequested, unknown).
  List<({OrderRecord record, PrintJob job})> get attentionJobs {
    final list = <({OrderRecord record, PrintJob job})>[];
    for (final record in _repository.allRecords()) {
      for (final job in record.jobs) {
        if (job.status == PrintStatus.failed ||
            job.status == PrintStatus.fallbackRequested ||
            job.status == PrintStatus.unknown) {
          list.add((record: record, job: job));
        }
      }
    }
    return list;
  }

  /// Sends a kitchen order with direct LAN printing and parallel background sync.
  ///
  /// Flow:
  /// 1. Ignore if send is already in progress (double-tap lock).
  /// 2. If [orderId] already exists locally, do nothing.
  /// 3. Save ONE local record atomically: `synced = false`, `rev = 1`, all jobs `pending`.
  /// 4. Print path: enqueue each job into per-printer FIFO queue (fire and forget).
  /// 5. Sync path, in parallel: trigger sync worker.
  Future<bool> sendToKitchen({
    required String orderId,
    required String localNo,
    required String tableId,
    required String tableName,
    required String diningMode,
    String? customerName,
    String? orderNote,
    required List<Map<String, dynamic>> items,
    required double total,
    required double tax,
  }) async {
    // 1. Ignore if send is already in progress
    if (_isSendInProgress) {
      LoggerService.warning('sendToKitchen: Send already in progress. Ignoring tap.');
      return false;
    }

    // 2. If this orderId already exists locally, do nothing (idempotency guard)
    if (_repository.exists(orderId)) {
      LoggerService.warning('sendToKitchen: Order $orderId already exists locally. Skipping.');
      return false;
    }

    _isSendInProgress = true;
    notifyListeners();

    try {
      final now = DateTime.now().toUtc();

      // Group items by target printer according to dish category
      final itemsByPrinter = <PrinterConfig, List<KitchenTicketItem>>{};

      for (final item in items) {
        final category = item['category'] as String? ?? 'General';
        final printer = _printerConfigService.getPrinterForCategory(category);

        final ticketItem = KitchenTicketItem(
          name: item['name'] as String? ?? 'Item',
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          itemNote: item['note'] as String?,
          category: category,
        );

        itemsByPrinter.putIfAbsent(printer, () => <KitchenTicketItem>[]).add(ticketItem);
      }

      // If no items were mapped, route to default kitchen printer
      if (itemsByPrinter.isEmpty) {
        final defaultPrn = PrinterConfigService.defaultPrinters.first;
        itemsByPrinter[defaultPrn] = const [];
      }

      // 3. Create print jobs (one jobId per printer)
      final jobs = <PrintJob>[];
      final ticketBytesMap = <PrintJob, List<int>>{};
      final printerMap = <PrintJob, PrinterConfig>{};

      for (final entry in itemsByPrinter.entries) {
        final printer = entry.key;
        final printerItems = entry.value;
        final jobId = UuidGenerator.v4();

        final ticketBytes = TicketBuilder.buildKitchenTicket(
          orderNo: localNo,
          tableName: tableName,
          diningMode: diningMode,
          customerName: customerName,
          orderNote: orderNote,
          items: printerItems,
          timestamp: now,
          isReprint: false,
          title: printer.role == 'bar' ? 'BAR ORDER TICKET' : 'KITCHEN ORDER TICKET (KOT)',
        );

        final rawTicketText = latin1.decode(ticketBytes);

        final job = PrintJob(
          jobId: jobId,
          printerId: printer.id,
          type: printer.role == 'bar' ? 'bar_kot' : 'kitchen_kot',
          ticketData: rawTicketText,
          status: PrintStatus.pending,
          createdAt: now,
        );

        jobs.add(job);
        ticketBytesMap[job] = ticketBytes;
        printerMap[job] = printer;
      }

      // 4. Save ONE local record atomically
      final record = OrderRecord(
        orderId: orderId,
        localNo: localNo,
        payload: {
          'tableId': tableId,
          'tableName': tableName,
          'diningMode': diningMode,
          'customerName': customerName,
          'orderNote': orderNote,
          'items': items,
          'total': total,
          'tax': tax,
        },
        jobs: jobs,
        synced: false,
        rev: 1,
        createdAt: now,
      );

      await _repository.save(record);

      // 5. Print path: put each job in per-printer FIFO queue (fire and forget)
      for (final job in jobs) {
        final printer = printerMap[job]!;
        final bytes = ticketBytesMap[job]!;

        _printQueue.enqueue(
          orderId: orderId,
          job: job,
          printer: printer,
          rawTicketBytes: bytes,
        );
      }

      // 6. Sync path in parallel: sync worker posts order to backend
      _syncService.triggerSync();

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      LoggerService.error('sendToKitchen error: $e', e, stackTrace);
      return false;
    } finally {
      _isSendInProgress = false;
      notifyListeners();
    }
  }

  /// Manually reprints a ticket, tagging it with `*** REPRINT ***` and logging user/time.
  Future<void> manualReprint({
    required String orderId,
    required String jobId,
    required String staffName,
    required String reason,
  }) async {
    final entry = _repository.getJob(jobId);
    if (entry == null) return;

    final record = entry.record;
    final printer = _printerConfigService.printers.cast<PrinterConfig?>().firstWhere(
      (p) => p!.id == entry.job.printerId,
      orElse: () => PrinterConfigService.defaultPrinters.first,
    )!;

    // Decode original ticket data and rebuild with prominent REPRINT watermark
    final itemsPayload = (record.payload['items'] as List<dynamic>?) ?? [];
    final ticketItems = itemsPayload.map((item) {
      final map = item as Map<String, dynamic>;
      return KitchenTicketItem(
        name: map['name'] as String? ?? 'Item',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        itemNote: map['note'] as String?,
      );
    }).toList();

    final reprintBytes = TicketBuilder.buildKitchenTicket(
      orderNo: record.localNo,
      tableName: record.payload['tableName'] as String? ?? '',
      diningMode: record.payload['diningMode'] as String? ?? '',
      customerName: record.payload['customerName'] as String?,
      orderNote: record.payload['orderNote'] as String?,
      items: ticketItems,
      timestamp: DateTime.now().toUtc(),
      isReprint: true,
      title: 'KITCHEN TICKET (REPRINT)',
    );

    LoggerService.info(
      'MANUAL REPRINT TRIGGERED: Order $orderId, Job $jobId, Staff: $staffName, Reason: $reason',
    );

    _printQueue.enqueue(
      orderId: orderId,
      job: entry.job.copyWith(status: PrintStatus.pending),
      printer: printer,
      rawTicketBytes: reprintBytes,
    );

    notifyListeners();
  }

  /// Resolves an [PrintStatus.unknown] job when staff verifies that the paper actually printed.
  Future<void> markJobAsPrinted(String orderId, String jobId) async {
    await _repository.setStatus(orderId, jobId, PrintStatus.printed);
    _syncService.triggerSync();
    notifyListeners();
  }

  /// Forces routing of a failed job to the server fallback print queue.
  Future<void> sendViaServer(String orderId, String jobId) async {
    await _repository.setStatus(orderId, jobId, PrintStatus.fallbackRequested);
    _syncService.triggerSync();
    notifyListeners();
  }
}

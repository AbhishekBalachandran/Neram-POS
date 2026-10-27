import 'dart:async';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/models/printer_config.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:neram_pos/features/printing/services/printer_service.dart';

typedef OnJobCompleted = void Function();
typedef OnPrintFallback = void Function(String orderId, PrintJob job, String error);

/// Per-printer FIFO print queue ensuring strict sequential execution for the same printer,
/// while allowing different physical printers to print concurrently in parallel.
class PrintQueue {
  PrintQueue({
    required this.repository,
    required this.printerService,
    this.onJobCompleted,
    this.onPrintFallback,
  });

  final LocalOrderRepository repository;
  final PrinterService printerService;
  final OnJobCompleted? onJobCompleted;
  final OnPrintFallback? onPrintFallback;

  LocalOrderRepository get _repository => repository;
  PrinterService get _printerService => printerService;
  OnJobCompleted? get _onJobCompleted => onJobCompleted;
  OnPrintFallback? get _onPrintFallback => onPrintFallback;

  // Dedicated execution chain per printer ID
  final Map<String, Future<void>> _printerChains = {};

  /// Enqueues a print job to its target printer's FIFO chain.
  /// Fire-and-forget: returns immediately without blocking caller.
  void enqueue({
    required String orderId,
    required PrintJob job,
    required PrinterConfig printer,
    required List<int> rawTicketBytes,
  }) {
    final printerId = printer.id;
    final currentChain = _printerChains[printerId] ?? Future.value();

    _printerChains[printerId] = currentChain.then((_) async {
      await _processJob(
        orderId: orderId,
        jobId: job.jobId,
        printer: printer,
        rawTicketBytes: rawTicketBytes,
      );
    }).catchError((error, stackTrace) {
      LoggerService.error('Unhandled printer chain error for $printerId: $error', error, stackTrace);
    });
  }

  Future<void> _processJob({
    required String orderId,
    required String jobId,
    required PrinterConfig printer,
    required List<int> rawTicketBytes,
  }) async {
    final entry = _repository.getJob(jobId);
    if (entry == null) return;

    final currentJob = entry.job;

    // 1. Duplicate guard: skip if already printed, serverPrinted, or fallbackRequested
    if (!currentJob.status.canDirectPrint) {
      LoggerService.debug(
        'PrintQueue: Skipping job $jobId (status: ${currentJob.status.name})',
      );
      return;
    }

    // 2. Mark job as printing
    await _repository.setStatus(orderId, jobId, PrintStatus.printing);

    var success = false;
    String lastError = '';

    // 3. Try 3 attempts with 300ms * attempt backoff delay
    for (var attempt = 1; attempt <= 3; attempt++) {
      final stopwatch = Stopwatch()..start();
      try {
        LoggerService.debug(
          'PrintQueue: Attempt $attempt/3 for job $jobId on ${printer.name} (${printer.ip}:${printer.port})',
        );

        await _printerService.printRaw(
          printer.ip,
          printer.port,
          rawTicketBytes,
          connectTimeout: const Duration(seconds: 3),
          overallTimeout: const Duration(seconds: 5),
        );

        stopwatch.stop();
        success = true;

        // Log successful print attempt
        LoggerService.info(
          'PRINT SUCCESS [orderId: $orderId, jobId: $jobId, printer: ${printer.name}, '
          'attempt: $attempt, duration: ${stopwatch.elapsedMilliseconds}ms]',
        );

        // Mark printed in local repository (duplicate guard + rev increment)
        await _repository.setStatus(orderId, jobId, PrintStatus.printed);

        // Trigger sync in parallel
        _onJobCompleted?.call();
        break;
      } catch (e) {
        stopwatch.stop();
        lastError = e.toString();

        LoggerService.warning(
          'PRINT FAILED [orderId: $orderId, jobId: $jobId, printer: ${printer.name}, '
          'attempt: $attempt/3, error: $lastError, duration: ${stopwatch.elapsedMilliseconds}ms]',
        );

        await _repository.setError(
          orderId,
          jobId,
          lastError,
          newStatus: attempt < 3 ? PrintStatus.printing : null,
        );

        if (attempt < 3) {
          // Wait 300ms * attempt between retries
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    // 4. After 3 failures: mark fallbackRequested, trigger sync and notify UI
    if (!success) {
      LoggerService.error(
        'PRINT EXHAUSTED: Marking job $jobId as fallbackRequested after 3 failed attempts.',
      );

      final updatedRecord = await _repository.setStatus(
        orderId,
        jobId,
        PrintStatus.fallbackRequested,
      );

      final failedJob = updatedRecord?.jobs.firstWhere(
        (j) => j.jobId == jobId,
        orElse: () => currentJob,
      );

      // Trigger sync so backend can take over printing
      _onJobCompleted?.call();

      // Notify UI
      if (failedJob != null) {
        _onPrintFallback?.call(orderId, failedJob, lastError);
      }
    }
  }

  /// Wait for all active printer queues to drain (useful for tests and graceful shutdown).
  Future<void> drainAll() async {
    await Future.wait(_printerChains.values);
  }
}

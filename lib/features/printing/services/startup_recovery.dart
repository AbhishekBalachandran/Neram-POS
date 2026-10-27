import 'dart:convert';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:neram_pos/features/printing/services/print_queue.dart';
import 'package:neram_pos/features/printing/services/printer_config_service.dart';
import 'package:neram_pos/features/printing/services/sync_service.dart';

/// Recovers print jobs and synchronization state after app restart or unexpected kill.
abstract final class StartupRecovery {
  /// Runs startup recovery:
  /// 1. Finds all jobs in [PrintStatus.printing] and sets them to [PrintStatus.unknown]
  ///    (never auto-reprinted to avoid duplicate tickets after app kill).
  /// 2. Re-enqueues jobs in [PrintStatus.pending] or [PrintStatus.failed].
  /// 3. Initiates background sync drain for unsynced records.
  static Future<void> recover({
    required LocalOrderRepository repository,
    required PrintQueue printQueue,
    required PrinterConfigService printerConfigService,
    required SyncService syncService,
  }) async {
    LoggerService.info('StartupRecovery: Initiating print queue and order recovery.');

    final allRecords = repository.allRecords();
    var unknownCount = 0;
    var reEnqueuedCount = 0;

    for (final record in allRecords) {
      for (final job in record.jobs) {
        if (job.status == PrintStatus.printing) {
          // Rule: Set jobs found in 'printing' to 'unknown' and NEVER auto-reprint them
          await repository.setStatus(record.orderId, job.jobId, PrintStatus.unknown);
          unknownCount++;
          LoggerService.warning(
            'StartupRecovery: Job ${job.jobId} was in printing state at kill; '
            'marked as unknown to prevent double printing.',
          );
        } else if (job.status == PrintStatus.pending || job.status == PrintStatus.failed) {
          // Rule: Re-enqueue jobs in pending or failed
          final printer = printerConfigService.printers.cast<dynamic>().firstWhere(
            (p) => p.id == job.printerId,
            orElse: () => PrinterConfigService.defaultPrinters.first,
          );

          printQueue.enqueue(
            orderId: record.orderId,
            job: job,
            printer: printer,
            rawTicketBytes: latin1.encode(job.ticketData),
          );
          reEnqueuedCount++;
        }
      }
    }

    LoggerService.info(
      'StartupRecovery: Completed. Marked $unknownCount jobs as unknown, '
      're-enqueued $reEnqueuedCount jobs. Triggering sync drain.',
    );

    // Rule: Then trigger sync
    await syncService.triggerSync();
  }
}

import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';
import 'package:neram_pos/features/printing/services/hybrid_print_manager.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet displaying print queue status for failed, fallback, and unknown jobs.
/// Provides interactive actions:
/// - "Did this print?" prompt for unknown jobs (Reprint / Mark as printed)
/// - Retry direct LAN print
/// - Force send via server fallback queue
class PrintStatusModal extends StatelessWidget {
  const PrintStatusModal({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.selection();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PrintStatusModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final printManager = context.watch<HybridPrintManager>();
    final attentionJobs = printManager.attentionJobs;
    final unsyncedCount = printManager.unsyncedOrdersCount;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x60000000),
              blurRadius: 32,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.print_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Print & Sync Status',
                            style: AppTypography.headlineFont(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            unsyncedCount > 0
                                ? '$unsyncedCount order(s) pending sync'
                                : 'All orders synced',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(
              height: 24,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),

            // List of Attention Jobs or Clean State
            Flexible(
              child: attentionJobs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 44,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'All Print Jobs Dispatched',
                              style: AppTypography.headlineFont(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No pending printer errors or unconfirmed tickets.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: attentionJobs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = attentionJobs[index];
                        final record = entry.record;
                        final job = entry.job;
                        return _buildJobCard(context, isDark, record.orderId, record.localNo, job);
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    bool isDark,
    String orderId,
    String localNo,
    dynamic job,
  ) {
    final printManager = context.read<HybridPrintManager>();
    final authVm = context.read<AuthViewModel>();
    final staffName = authVm.currentUser?.name ?? 'Staff';

    final isUnknown = job.status == PrintStatus.unknown;
    final isFallback = job.status == PrintStatus.fallbackRequested;

    final badgeColor = isUnknown
        ? AppColors.secondary
        : (isFallback ? AppColors.primary : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order $localNo',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.status.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Printer: ${job.printerId} • Attempts: ${job.attempts}',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          if (job.lastError != null && job.lastError!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${job.lastError}',
              style: const TextStyle(fontSize: 11, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 12),

          // Interactive action row
          if (isUnknown) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.help_outline_rounded, size: 16, color: AppColors.secondary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'App was interrupted during print. Did this physical ticket print?',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticService.selection();
                      printManager.markJobAsPrinted(orderId, job.jobId);
                    },
                    child: const Text('Yes, Printed', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      HapticService.selection();
                      printManager.manualReprint(
                        orderId: orderId,
                        jobId: job.jobId,
                        staffName: staffName,
                        reason: 'Recovered after app restart - paper not found',
                      );
                    },
                    child: const Text('No, Reprint', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('Retry Print', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      HapticService.selection();
                      printManager.manualReprint(
                        orderId: orderId,
                        jobId: job.jobId,
                        staffName: staffName,
                        reason: 'Manual retry from print status sheet',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.cloud_upload_rounded, size: 14),
                    label: const Text('Send via Server', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      HapticService.selection();
                      printManager.sendViaServer(orderId, job.jobId);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

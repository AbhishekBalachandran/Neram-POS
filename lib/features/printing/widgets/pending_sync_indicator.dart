import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/features/printing/services/hybrid_print_manager.dart';
import 'package:neram_pos/features/printing/widgets/print_status_modal.dart';
import 'package:provider/provider.dart';

/// Minimal additive UI pill showing "N orders pending sync" when unsynced orders exist.
/// Tapping opens the [PrintStatusModal] to review sync and printer statuses.
class PendingSyncIndicator extends StatelessWidget {
  const PendingSyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final printManager = Provider.of<HybridPrintManager?>(context);
    if (printManager == null) return const SizedBox.shrink();

    final count = printManager.unsyncedOrdersCount;
    final hasAttentionJobs = printManager.attentionJobs.isNotEmpty;

    if (count == 0 && !hasAttentionJobs) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = hasAttentionJobs ? AppColors.warning : AppColors.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticService.selection();
          PrintStatusModal.show(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.20 : 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.40)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasAttentionJobs
                    ? Icons.print_disabled_rounded
                    : Icons.sync_rounded,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                count > 0 ? '$count Pending Sync' : 'Print Issues',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

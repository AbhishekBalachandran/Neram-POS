import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/viewmodels/stock_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet for conducting the weekly kitchen stocktake & physical inventory count.
class StockAuditModal extends StatefulWidget {
  const StockAuditModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StockAuditModal(),
    );
  }

  @override
  State<StockAuditModal> createState() => _StockAuditModalState();
}

class _StockAuditModalState extends State<StockAuditModal> {
  final Set<String> _verifiedItemIds = {};
  final TextEditingController _notesController = TextEditingController(
    text: 'Weekly routine inventory stocktake complete. All physical containers verified against recorded levels.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onConfirmAudit() {
    final stockVM = context.read<StockViewModel>();
    stockVM.completeAudit(
      staffName: 'Abhishek (Manager)',
      notes: _notesController.text.trim(),
    );

    HapticService.mediumImpact();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly stocktake completed & verified by Manager!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final inputBg = isDark ? const Color(0xFF16171B) : const Color(0xFFF4F4F6);
    final stockVM = context.watch<StockViewModel>();
    final items = stockVM.allItems;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF4A4B53) : const Color(0xFFD0D3D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.tertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Kitchen Stocktake',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last audited: ${DateFormat('dd MMM yyyy').format(stockVM.lastKitchenAudit)} by ${stockVM.lastAuditedBy}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Checklist description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Tap items below to verify physical count matches current digital records.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'PHYSICAL VERIFICATION CHECKLIST (${_verifiedItemIds.length}/${items.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Item check chips/tiles
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isChecked = _verifiedItemIds.contains(item.id);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _verifiedItemIds.remove(item.id);
                          } else {
                            _verifiedItemIds.add(item.id);
                          }
                        });
                        HapticService.selection();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? AppColors.success.withValues(alpha: 0.12)
                              : inputBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isChecked
                                ? AppColors.success
                                : (isDark ? const Color(0xFF282A30) : const Color(0xFFE2E4E9)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: isChecked ? AppColors.success : AppColors.darkTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${item.currentStock} ${item.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item.isLowStock ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Audit Notes
              Text(
                'AUDIT SIGN-OFF NOTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                  ),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _onConfirmAudit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.verified_rounded, size: 20),
                  label: const Text(
                    'SIGN OFF & COMPLETE AUDIT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

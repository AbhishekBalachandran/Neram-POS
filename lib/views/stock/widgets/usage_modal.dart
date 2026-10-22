import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/viewmodels/stock_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet for logging ingredient usage, kitchen prep, or spoilage.
class UsageModal extends StatefulWidget {
  const UsageModal({
    super.key,
    required this.item,
  });

  final StockItemModel item;

  static Future<void> show(BuildContext context, StockItemModel item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UsageModal(item: item),
    );
  }

  @override
  State<UsageModal> createState() => _UsageModalState();
}

class _UsageModalState extends State<UsageModal> {
  late final TextEditingController _quantityController;
  late final TextEditingController _customReasonController;
  final double _quantity = 1.0;
  String _selectedReason = 'Shift Service Consumption';

  final List<String> _quickReasons = const [
    'Shift Service Consumption',
    'Morning Batch Prep',
    'Kitchen Spoilage / Expired',
    'Accidental Spill / Damage',
    'Quality Audit / Recipe Test',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1.0');
    _customReasonController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customReasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final parsed = double.tryParse(_quantityController.text) ?? _quantity;
    if (parsed <= 0) return;

    if (parsed > widget.item.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot deduct $parsed ${widget.item.unit}. Only ${widget.item.currentStock} ${widget.item.unit} available in stock!',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reason = _customReasonController.text.trim().isNotEmpty
        ? _customReasonController.text.trim()
        : _selectedReason;

    final stockVM = context.read<StockViewModel>();
    stockVM.recordUsage(
      itemId: widget.item.id,
      usedQuantity: parsed,
      reason: reason,
    );

    HapticService.mediumImpact();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recorded -$parsed ${widget.item.unit} usage for ${widget.item.name}',
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final inputBg = isDark ? const Color(0xFF16171B) : const Color(0xFFF4F4F6);

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
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record Stock Usage',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Available on Hand: ${widget.item.currentStock} ${widget.item.unit}',
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

              const SizedBox(height: AppSpacing.lg),

              // Quantity Input
              Text(
                'CONSUMPTION QUANTITY (${widget.item.unit.toUpperCase()})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                  ),
                ),
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: widget.item.unit,
                    suffixStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Reason Selector
              Text(
                'SELECT USAGE REASON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickReasons.map((reason) {
                  final isSelected = _selectedReason == reason;
                  return ChoiceChip(
                    label: Text(reason),
                    selected: isSelected,
                    selectedColor: AppColors.secondary.withValues(alpha: 0.25),
                    backgroundColor: inputBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondary
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.secondary : Colors.transparent,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedReason = reason);
                        HapticService.selection();
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Custom Notes
              Text(
                'CUSTOM LOG NOTE (OPTIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                  ),
                ),
                child: TextField(
                  controller: _customReasonController,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add specific details (e.g. Expired batch #081)',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF6B6C75) : const Color(0xFFA0A3AB),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                  label: const Text(
                    'DEDUCT & RECORD USAGE',
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

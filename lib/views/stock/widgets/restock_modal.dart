import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/viewmodels/stock_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet allowing staff to inward stock for an item with quick stepper pills.
class RestockModal extends StatefulWidget {
  const RestockModal({
    super.key,
    required this.item,
  });

  final StockItemModel item;

  static Future<void> show(BuildContext context, StockItemModel item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RestockModal(item: item),
    );
  }

  @override
  State<RestockModal> createState() => _RestockModalState();
}

class _RestockModalState extends State<RestockModal> {
  late final TextEditingController _quantityController;
  late final TextEditingController _invoiceController;
  double _quantity = 5.0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.minLevel > 0
        ? (widget.item.minLevel - widget.item.currentStock).clamp(1.0, 500.0)
        : 5.0;
    _quantityController = TextEditingController(text: _quantity.toStringAsFixed(1));
    _invoiceController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  void _addQuantity(double delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(0.5, 9999.0);
      _quantityController.text = _quantity.toStringAsFixed(1);
    });
    HapticService.selection();
  }

  void _onConfirm() {
    final parsed = double.tryParse(_quantityController.text) ?? _quantity;
    if (parsed <= 0) return;

    final stockVM = context.read<StockViewModel>();
    stockVM.restockItem(
      itemId: widget.item.id,
      addedQuantity: parsed,
      invoiceNumber: _invoiceController.text.trim().isNotEmpty
          ? _invoiceController.text.trim()
          : null,
    );

    HapticService.mediumImpact();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully restocked +$parsed ${widget.item.unit} for ${widget.item.name}',
        ),
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

              // Title and Current Stock Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restock Item',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Current Stock: ${widget.item.currentStock} ${widget.item.unit} • Min Level: ${widget.item.minLevel} ${widget.item.unit}',
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

              // Quantity Stepper & Manual Input
              Text(
                'QUANTITY TO RESTOCK (${widget.item.unit.toUpperCase()})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              Row(
                children: [
                  // Decrement
                  IconButton.filledTonal(
                    onPressed: () => _addQuantity(-1.0),
                    icon: const Icon(Icons.remove_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: inputBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Value display/input
                  Expanded(
                    child: Container(
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixText: widget.item.unit,
                          suffixStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null && parsed >= 0) {
                            _quantity = parsed;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Increment
                  IconButton.filledTonal(
                    onPressed: () => _addQuantity(1.0),
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: inputBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Quick Increments
              Wrap(
                spacing: 8,
                children: [2.0, 5.0, 10.0, 20.0, 50.0].map((step) {
                  return ActionChip(
                    label: Text('+$step'),
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    backgroundColor: inputBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide.none,
                    onPressed: () => _addQuantity(step),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Optional PO / Invoice Number
              Text(
                'PURCHASE INVOICE / PO REF (OPTIONAL)',
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
                  controller: _invoiceController,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. INV-2026-9041 (${widget.item.supplier})',
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text(
                    'CONFIRM INWARD RESTOCK',
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

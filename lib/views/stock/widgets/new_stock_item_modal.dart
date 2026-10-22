import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/viewmodels/stock_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet for registering a new inventory item in the catalog.
class NewStockItemModal extends StatefulWidget {
  const NewStockItemModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewStockItemModal(),
    );
  }

  @override
  State<NewStockItemModal> createState() => _NewStockItemModalState();
}

class _NewStockItemModalState extends State<NewStockItemModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _initialStockController = TextEditingController(text: '10');
  final _minLevelController = TextEditingController(text: '5');
  final _costController = TextEditingController(text: '250');
  final _supplierController = TextEditingController();

  StockCategory _selectedCategory = StockCategory.foodRaw;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _initialStockController.dispose();
    _minLevelController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final initialStock = double.tryParse(_initialStockController.text) ?? 0.0;
    final minLevel = double.tryParse(_minLevelController.text) ?? 1.0;
    final cost = double.tryParse(_costController.text) ?? 0.0;
    final supplier = _supplierController.text.trim().isNotEmpty
        ? _supplierController.text.trim()
        : 'Direct Procurement';

    final stockVM = context.read<StockViewModel>();
    stockVM.addNewItem(
      name: name,
      category: _selectedCategory,
      unit: unit,
      initialStock: initialStock,
      minLevel: minLevel,
      costPerUnit: cost,
      supplier: supplier,
    );

    HapticService.mediumImpact();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registered "$name" in stock catalog'),
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
          child: Form(
            key: _formKey,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_box_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Add New Stock Item',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
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

                // Item Name
                Text(
                  'ITEM NAME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter item name' : null,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Colombian Supremo Coffee Beans',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF6B6C75) : const Color(0xFFA0A3AB),
                    ),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Category selector
                Text(
                  'INVENTORY CATEGORY',
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
                  children: StockCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.displayName),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      backgroundColor: inputBg,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedCategory = cat);
                          HapticService.selection();
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Unit and Supplier Row
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEASUREMENT UNIT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _unitController,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'kg, Litre, pcs',
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUPPLIER NAME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _supplierController,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Nilgiri Roasters',
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Numbers Grid: Initial Stock, Min Level, Cost
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INITIAL STOCK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _initialStockController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid' : null,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MIN. REORDER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _minLevelController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid' : null,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COST / UNIT (₹)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _costController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid' : null,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF373A43) : const Color(0xFFE2E4E9),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Save CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _onSave,
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
                      'ADD TO INVENTORY CATALOG',
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
      ),
    );
  }
}

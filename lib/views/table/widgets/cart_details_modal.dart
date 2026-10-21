import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/data/models/dish_model.dart';
import 'package:neram_pos/viewmodels/table_viewmodel.dart';
import 'package:neram_pos/views/table/widgets/all_tables_bottom_sheet.dart';
import 'package:provider/provider.dart';

/// Animated Order Sheet matching the Google Stitch "NERAM POS - Animated Order Sheet" specification.
/// Features interactive dining mode switcher, table picker, customer name input, ordered dishes
/// with steppers and kitchen notes, live bill breakdown, and the flame gradient KOT dispatch button.
class CartDetailsModal extends StatefulWidget {
  const CartDetailsModal({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.selection();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartDetailsModal(),
    );
  }

  @override
  State<CartDetailsModal> createState() => _CartDetailsModalState();
}

class _CartDetailsModalState extends State<CartDetailsModal> {
  late final TextEditingController _guestController;

  @override
  void initState() {
    super.initState();
    final tableViewModel = context.read<TableViewModel>();
    _guestController = TextEditingController(text: tableViewModel.customerName);
  }

  @override
  void dispose() {
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tableViewModel = context.watch<TableViewModel>();
    final cartItems = tableViewModel.currentTableCart;
    final dishes = tableViewModel.dishes;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLowest
            : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 40,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sheet Drag Handle
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Modal Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(
                          children: [
                            Text(
                              'Current Order',
                              style: AppTypography.headlineFont(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tableViewModel.totalCartItemCount} Items',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review items, station & dispatch to kitchen',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        foregroundColor: AppColors.error,
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        tableViewModel.clearCart();
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Dining Mode Segmented Switcher
                  _buildDiningModeSwitcher(isDark, tableViewModel),
                  const SizedBox(height: AppSpacing.sm + 4),

                  // 2. Table / Station Picker
                  _buildTablePicker(context, isDark, tableViewModel),
                  const SizedBox(height: AppSpacing.sm + 4),

                  // 3. Customer / Guest Name
                  _buildCustomerNameInput(isDark, tableViewModel),
                  const SizedBox(height: AppSpacing.sm + 4),

                  // 4. Ordered Dishes List with Steppers & Notes
                  _buildOrderedDishesList(
                    context,
                    isDark,
                    tableViewModel,
                    cartItems,
                    dishes,
                  ),
                  const SizedBox(height: AppSpacing.sm + 4),

                  // 5. Dynamic Pricing & Bill Breakdown
                  _buildPricingBreakdown(isDark, tableViewModel),
                ],
              ),
            ),
          ),

          // Multi-Action Footer Bar
          _buildFooterActions(context, isDark, tableViewModel),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. DINING MODE SWITCHER
  // ---------------------------------------------------------------------------
  Widget _buildDiningModeSwitcher(bool isDark, TableViewModel tableViewModel) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DINING MODE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  tableViewModel.diningMode.displayName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 3-Segment Button Grid
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  mode: DiningMode.dineIn,
                  icon: Icons.table_restaurant_rounded,
                  label: 'Table',
                  sub: 'Dine-in',
                  isSelected: tableViewModel.diningMode == DiningMode.dineIn,
                  onTap: () => tableViewModel.setDiningMode(DiningMode.dineIn),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildModeButton(
                  mode: DiningMode.outdoor,
                  icon: Icons.deck_rounded,
                  label: 'Outdoor',
                  sub: 'Unified Area',
                  isSelected: tableViewModel.diningMode == DiningMode.outdoor,
                  onTap: () => tableViewModel.setDiningMode(DiningMode.outdoor),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildModeButton(
                  mode: DiningMode.takeaway,
                  icon: Icons.shopping_bag_rounded,
                  label: 'Takeaway',
                  sub: 'Pickup Token',
                  isSelected: tableViewModel.diningMode == DiningMode.takeaway,
                  onTap: () =>
                      tableViewModel.setDiningMode(DiningMode.takeaway),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required DiningMode mode,
    required IconData icon,
    required String label,
    required String sub,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x40FF6B35),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. TABLE / STATION PICKER
  // ---------------------------------------------------------------------------
  Widget _buildTablePicker(
    BuildContext context,
    bool isDark,
    TableViewModel tableViewModel,
  ) {
    final quickTables = ['T-01', 'T-02', 'T-03', 'T-04', 'OD-01', 'TK-14'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chair_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TABLE / STATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                tableViewModel.selectedTable.subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Quick Table Selection Pills with Grid browse button
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: quickTables.map((tid) {
                      final isSelected = tableViewModel.selectedTableId == tid;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => tableViewModel.selectTable(tid),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                    ? AppColors.darkSurfaceContainerLowest
                                    : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              child: Text(
                                tid,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Open Full Grid Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.of(context).pop();
                    AllTablesBottomSheet.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainerHigh
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.grid_view_rounded, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Grid',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. CUSTOMER / GUEST NAME INPUT
  // ---------------------------------------------------------------------------
  Widget _buildCustomerNameInput(bool isDark, TableViewModel tableViewModel) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                size: 15,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'CUSTOMER / GUEST NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainerLowest
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(
                  Icons.badge_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _guestController,
                    onChanged: tableViewModel.setCustomerName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter guest name (e.g. Alex M.)',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ORDERED DISHES LIST WITH STEPPERS & NOTES
  // ---------------------------------------------------------------------------
  Widget _buildOrderedDishesList(
    BuildContext context,
    bool isDark,
    TableViewModel tableViewModel,
    Map<String, int> cartItems,
    List<DishModel> dishes,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.dinner_dining_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ORDERED DISHES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                'Tap + / - to adjust',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Dish Rows
          if (cartItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No items in order yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            )
          else
            ...cartItems.entries.map((entry) {
              final dish = dishes.firstWhere(
                (d) => d.id == entry.key,
                orElse: () => dishes.first,
              );
              final qty = entry.value;
              final lineTotal = dish.price * qty;
              final note = tableViewModel.itemNotes[dish.id];

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.3)
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Food Type Indicator
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: dish.foodType == FoodType.veg
                                  ? const Color(0xFF10B981)
                                  : dish.foodType == FoodType.egg
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dish.foodType == FoodType.veg
                                  ? const Color(0xFF10B981)
                                  : dish.foodType == FoodType.egg
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Title & Unit Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.name,
                                style: AppTypography.headlineFont(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                '${dish.formattedPrice} each',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stepper [-] [qty] [+]
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceContainerLowest
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 26,
                                  minHeight: 26,
                                ),
                                icon: const Icon(
                                  Icons.remove_rounded,
                                  size: 14,
                                ),
                                onPressed: () =>
                                    tableViewModel.removeDish(dish),
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 26,
                                  minHeight: 26,
                                ),
                                icon: const Icon(Icons.add_rounded, size: 14),
                                onPressed: () => tableViewModel.addDish(dish),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Line Total
                        SizedBox(
                          width: 52,
                          child: Text(
                            '\$${lineTotal.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: AppTypography.headlineFont(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Special Notes Pill if available
                    if (note != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceContainerLowest
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit_note_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                note,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          const SizedBox(height: AppSpacing.sm),

          // Dashed "Add More Dishes" button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                HapticService.selection();
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerLowest
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    style: BorderStyle.solid,
                  ),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Add More Dishes (Back to Menu)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. DYNAMIC PRICING & BILL BREAKDOWN
  // ---------------------------------------------------------------------------
  Widget _buildPricingBreakdown(bool isDark, TableViewModel tableViewModel) {
    final subtotal = tableViewModel.cartSubtotal;
    final tax = tableViewModel.cartTax;
    final total = tableViewModel.cartTotalPayable;
    final itemCount = tableViewModel.totalCartItemCount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($itemCount items)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GST / Taxes (5%)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '\$${tax.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Charge',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Text(
                'FREE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Payable',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Inclusive of all taxes',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppTypography.headlineFont(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. MULTI-ACTION FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildFooterActions(
    BuildContext context,
    bool isDark,
    TableViewModel tableViewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLow
            : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Row with 3 Secondary Actions
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryActionButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Menu',
                    isDark: isDark,
                    onTap: () {
                      HapticService.selection();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSecondaryActionButton(
                    icon: Icons.bookmark_rounded,
                    label: 'Save Draft',
                    isDark: isDark,
                    onTap: () {
                      HapticService.mediumImpact();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Order draft saved.'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSecondaryActionButton(
                    icon: Icons.receipt_rounded,
                    label: 'Request Bill',
                    isDark: isDark,
                    onTap: () {
                      HapticService.selection();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Bill requested for ${tableViewModel.selectedTable.name}.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Primary Send to Kitchen Action with Flame Gradient
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  tableViewModel.sendOrderToKitchen();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Order sent to Kitchen for ${tableViewModel.selectedTable.name}!',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4DFF6B35),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.soup_kitchen_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Send to Kitchen (KOT)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerHigh
                : AppColors.lightSurfaceSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/utils/currency_formatter.dart';
import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/viewmodels/stock_viewmodel.dart';
import 'package:neram_pos/views/stock/widgets/new_stock_item_modal.dart';
import 'package:neram_pos/views/stock/widgets/stock_audit_modal.dart';
import 'package:provider/provider.dart';

/// Complete Stock & Inventory Management view converted from the Google Stitch
/// "NERAM POS - Stocks & Inventory Management" screen.
/// Features high-contrast dark hospitality aesthetic, live search & category filtering,
/// priority restock alerts, interactive card-tables, and instant inward/usage workflows.
class StockTabView extends StatefulWidget {
  const StockTabView({super.key});

  @override
  State<StockTabView> createState() => _StockTabViewState();
}

class _StockTabViewState extends State<StockTabView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortSheet(BuildContext context, StockViewModel stockVM) {
    HapticService.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1F24) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    'SORT INVENTORY BY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...StockSortOption.values.map((option) {
                  final isSelected = stockVM.sortOption == option;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.darkTextSecondary,
                      size: 20,
                    ),
                    title: Text(
                      option.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                      ),
                    ),
                    onTap: () {
                      stockVM.setSortOption(option);
                      HapticService.selection();
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stockVM = context.watch<StockViewModel>();
    final items = stockVM.filteredItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 720;
        final horizontalPadding = isTablet ? 24.0 : 16.0;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticService.lightImpact();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section: Title & New Item Action
                _buildHeader(context, isDark, stockVM),
                const SizedBox(height: AppSpacing.md),

                // High-Priority Restock Alert Banner
                if (stockVM.lowAlertCount > 0) ...[
                  _buildAlertBanner(context, isDark, stockVM),
                  const SizedBox(height: AppSpacing.md),
                ],

                // 4 Summary Metrics Cards
                _buildMetricsGrid(context, isDark, stockVM, isTablet),
                const SizedBox(height: AppSpacing.md),

                // Search & Sort Bar
                _buildSearchBar(context, isDark, stockVM),
                const SizedBox(height: AppSpacing.sm),

                // Horizontal Category Selector Tabs
                _buildCategoryPills(context, isDark, stockVM),
                const SizedBox(height: AppSpacing.sm),

                // Filter Status & Low Stock Toggle
                _buildFilterStatusBar(context, isDark, stockVM),
                const SizedBox(height: AppSpacing.md),

                // Inventory Items List / Grid
                if (items.isEmpty)
                  _buildEmptyState(context, isDark, stockVM)
                else
                  _buildItemsList(context, isDark, items, isTablet),

                const SizedBox(height: AppSpacing.xl),

                // Weekly Kitchen Stocktake Audit Banner Card
                _buildAuditBannerCard(context, isDark, stockVM),

                // Bottom safety space for navigation bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Top Screen Header with Brand Category Title & Primary "Add New Item" CTA on a dedicated new line
  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Stock & Inventory',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: isDark ? AppColors.primary : AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Inventory Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // "Add New Item" CTA Button moved to new line to prevent congestion/overflow
        FilledButton.icon(
          onPressed: () {
            HapticService.selection();
            NewStockItemModal.show(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.35),
          ),
          icon: const Icon(Icons.add_box_rounded, size: 20),
          label: const Text(
            'Add New Item',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// High Priority Restock Alert Banner matching the Stitch specification
  Widget _buildAlertBanner(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    final isFilteringLow = stockVM.isLowStockOnly;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.selection();
          stockVM.toggleLowStockFilter();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2E1911),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFilteringLow
                  ? AppColors.primary
                  : const Color(0xFF5D2816),
              width: isFilteringLow ? 1.8 : 1.0,
            ),
            boxShadow: [
              if (isFilteringLow)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notification_important_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${stockVM.lowAlertCount} Items Low on Stock',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),

                    Text(
                      isFilteringLow
                          ? 'Filtering active — showing low stock items only'
                          : 'Tap to show priority restock supplies',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFilteringLow
                      ? Icons.filter_alt_off_rounded
                      : Icons.filter_list_rounded,
                  size: 16,
                  color: isFilteringLow ? AppColors.primary : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4 Summary Metric Cards in responsive layout
  Widget _buildMetricsGrid(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
    bool isTablet,
  ) {
    final surfaceColor = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF282A30)
        : const Color(0xFFE8EAF0);

    final cards = [
      _MetricData(
        title: 'Total Items',
        value: '${stockVM.totalItemsCount}',
        icon: Icons.inventory_rounded,
        iconColor: AppColors.secondary,
        isWarning: false,
      ),
      _MetricData(
        title: 'Low Alert',
        value: '${stockVM.lowAlertCount}',
        icon: Icons.warning_rounded,
        iconColor: AppColors.primary,
        isWarning: stockVM.lowAlertCount > 0,
      ),
      _MetricData(
        title: 'Out of Stock',
        value: '${stockVM.outOfStockCount}',
        icon: Icons.check_circle_rounded,
        iconColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        isWarning: false,
      ),
      _MetricData(
        title: 'Total Value',
        value: CurrencyFormatter.format(stockVM.totalStockValue),
        icon: Icons.currency_rupee_rounded,
        iconColor: AppColors.tertiary,
        isWarning: false,
      ),
    ];

    if (isTablet) {
      return Row(
        children: cards.map((c) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildMetricCard(c, surfaceColor, borderColor, isDark),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                cards[0],
                surfaceColor,
                borderColor,
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                cards[1],
                surfaceColor,
                borderColor,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                cards[2],
                surfaceColor,
                borderColor,
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                cards[3],
                surfaceColor,
                borderColor,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    _MetricData data,
    Color surfaceColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: data.isWarning
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: data.isWarning
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
        ],
      ),
    );
  }

  /// Search & Sort Bar
  Widget _buildSearchBar(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    final inputBg = isDark ? const Color(0xFF1A1B20) : const Color(0xFFF3F4F6);
    final borderColor = isDark
        ? const Color(0xFF292A2F)
        : const Color(0xFFE5E7EB);

    return Row(
      children: [
        // Live search textfield
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: stockVM.setSearchQuery,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 20,
                ),
                suffixIcon: stockVM.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          stockVM.setSearchQuery('');
                        },
                      )
                    : null,
                hintText: 'Search items, category, supplier or unit...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF6B6C75)
                      : const Color(0xFFA0A3AB),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Sort Button
        InkWell(
          onTap: () => _showSortSheet(context, stockVM),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1F24) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swap_vert_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'SORT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Horizontal Category Selector Tabs
  Widget _buildCategoryPills(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    final categories = [
      {'code': 'all', 'label': 'All Items (${stockVM.totalItemsCount})'},
      {'code': 'food', 'label': 'Stock (Food & Raw)'},
      {'code': 'consumables', 'label': 'Consumables'},
      {'code': 'small_equip', 'label': 'Small Equipment'},
      {'code': 'fixed', 'label': 'Fixed Assets'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = stockVM.selectedCategoryCode == cat['code'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark
                  ? const Color(0xFF1E1F24)
                  : const Color(0xFFF3F4F6),
              labelStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.black
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? const Color(0xFF2E3038)
                          : const Color(0xFFE5E7EB)),
              ),
              onSelected: (val) {
                if (val) {
                  stockVM.setCategory(cat['code']!);
                  HapticService.selection();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Filter Status & Low Stock Toggle
  Widget _buildFilterStatusBar(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: stockVM.isLowStockOnly
                ? AppColors.primary.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF292A2F) : const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            stockVM.isLowStockOnly
                ? '${stockVM.lowAlertCount} Low Stock Items'
                : (stockVM.selectedCategoryCode == 'all'
                      ? 'All Stock Items'
                      : 'Filtered Category'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: stockVM.isLowStockOnly
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
            ),
          ),
        ),
        // Show Low Stock Only chip toggle
        InkWell(
          onTap: () {
            HapticService.selection();
            stockVM.toggleLowStockFilter();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: stockVM.isLowStockOnly
                  ? AppColors.primary
                  : (isDark
                        ? const Color(0xFF1A1B20)
                        : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: stockVM.isLowStockOnly
                    ? AppColors.primary
                    : (isDark
                          ? const Color(0xFF2E3038)
                          : const Color(0xFFE2E4E9)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: stockVM.isLowStockOnly
                        ? Colors.black
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  stockVM.isLowStockOnly
                      ? 'Show All Items'
                      : 'Show Low Stock Only',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: stockVM.isLowStockOnly
                        ? Colors.black
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Empty state display when filter/search returns no matches
  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3038) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No matching inventory items found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query, clearing filters, or adding a new stock item.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              stockVM.setSearchQuery('');
              stockVM.setCategory('all');
              stockVM.setLowStockFilter(false);
            },
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }

  /// List of inventory card-tables (responsive 1 col mobile, 2 col tablet)
  Widget _buildItemsList(
    BuildContext context,
    bool isDark,
    List<StockItemModel> items,
    bool isTablet,
  ) {
    if (isTablet) {
      final leftColumn = <StockItemModel>[];
      final rightColumn = <StockItemModel>[];
      for (var i = 0; i < items.length; i++) {
        if (i % 2 == 0) {
          leftColumn.add(items[i]);
        } else {
          rightColumn.add(items[i]);
        }
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leftColumn.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildStockItemCard(context, isDark, leftColumn[index]);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rightColumn.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildStockItemCard(context, isDark, rightColumn[index]);
              },
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildStockItemCard(context, isDark, items[index]);
      },
    );
  }

  /// Individual Stock Card displaying only the requested attributes cleanly without overflow
  Widget _buildStockItemCard(
    BuildContext context,
    bool isDark,
    StockItemModel item,
  ) {
    final surfaceColor = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF282A30)
        : const Color(0xFFE8EAF0);
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final packetsLabel =
        '${item.displayPacketsCount} ${item.displayPacketsCount == 1 ? "packet" : "packets"}';
    final minPacketsLabel =
        '${item.displayMinPackets} ${item.displayMinPackets == 1 ? "packet" : "packets"}';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. First line: Item Name + Low badge if low stock
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    height: 1.3,
                  ),
                ),
              ),
              if (item.isLowStock) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.7),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Low',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: borderColor.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),

          // Key-Value Details Section (Row with spaceBetween)
          _buildKeyValueRow(
            label: 'Category',
            value: item.category.displayName,
            labelColor: secondaryTextColor,
            valueColor: primaryTextColor,
          ),
          _buildKeyValueRow(
            label: 'In Stock',
            value: '$packetsLabel, ${item.displayTotalAmount}, ${item.displayAmountPerPacket}',
            labelColor: secondaryTextColor,
            valueColor: item.isLowStock ? AppColors.error : primaryTextColor,
          ),
          _buildKeyValueRow(
            label: 'Cost',
            value: '₹${item.displayCostPerPacket.toStringAsFixed(2)} / packet, ₹${item.costPerUnit.toStringAsFixed(2)} / ${item.unit}',
            labelColor: secondaryTextColor,
            valueColor: primaryTextColor,
          ),
          _buildKeyValueRow(
            label: 'Min. Level',
            value: minPacketsLabel,
            labelColor: secondaryTextColor,
            valueColor: primaryTextColor,
          ),
          _buildKeyValueRow(
            label: 'Supplier',
            value: item.supplier,
            labelColor: secondaryTextColor,
            valueColor: primaryTextColor,
          ),
          const SizedBox(height: 14),

          // 7. Action buttons: Issue Stock & Alert Mgr
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  HapticService.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Issue Stock: ${item.name}'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.outbox_rounded, size: 16),
                label: const Text(
                  'Issue Stock',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  HapticService.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alert Manager for ${item.name}'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF3E4048)
                        : const Color(0xFFCBD0DC),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(
                  Icons.notification_important_outlined,
                  size: 16,
                ),
                label: const Text(
                  'Alert Mgr',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Key-Value item row with spaceBetween alignment and no truncation
  Widget _buildKeyValueRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    FontWeight valueWeight = FontWeight.w600,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelColor,
              height: 1.35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: valueWeight,
                color: valueColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Weekly Kitchen Stocktake Audit Banner Card
  Widget _buildAuditBannerCard(
    BuildContext context,
    bool isDark,
    StockViewModel stockVM,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF282A30) : const Color(0xFFE8EAF0),
        ),
      ),
      child: Row(
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
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last audited: ${stockVM.lastAuditedBy}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              HapticService.selection();
              StockAuditModal.show(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              'Start Audit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isWarning,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isWarning;
}

import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/widgets/app_bottom_sheet.dart';
import 'package:neram_pos/data/models/table_model.dart';
import 'package:neram_pos/viewmodels/table_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet presenting all 22 tables across Indoor, Outdoor, and Takeaway zones.
class AllTablesBottomSheet extends StatefulWidget {
  const AllTablesBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => const AllTablesBottomSheet(),
    );
  }

  @override
  State<AllTablesBottomSheet> createState() => _AllTablesBottomSheetState();
}

class _AllTablesBottomSheetState extends State<AllTablesBottomSheet> {
  String _selectedZoneFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tableViewModel = context.watch<TableViewModel>();
    final tables = tableViewModel.tables;
    final selectedId = tableViewModel.selectedTableId;

    final indoorTables = tables
        .where((t) => t.zone == TableZone.indoor)
        .toList();
    final outdoorTables = tables
        .where((t) => t.zone == TableZone.outdoor)
        .toList();
    final takeawayTables = tables
        .where((t) => t.zone == TableZone.takeaway)
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'All Tables & Zones',
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
                            color: isDark
                                ? AppColors.darkSurfaceContainerHigh
                                : AppColors.lightSurfaceSubtle,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '22 Tables',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any table card to select or assign orders',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
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
          ),
          const Divider(height: 1),

          // Zone Filter Tabs & Status Legend Strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            color: isDark
                ? AppColors.darkSurfaceContainerLow
                : AppColors.lightSurfaceSubtle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zone Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildZoneChip('all', 'All (22)', isDark),
                      const SizedBox(width: AppSpacing.xs),
                      _buildZoneChip('indoor', 'Indoor (12)', isDark),
                      const SizedBox(width: AppSpacing.xs),
                      _buildZoneChip('outdoor', 'Outdoor (6)', isDark),
                      const SizedBox(width: AppSpacing.xs),
                      _buildZoneChip('takeaway', 'Takeaway (4)', isDark),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs + 2),

                // Status Legend
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLegendDot(const Color(0xFF10B981), 'Vacant'),
                      const SizedBox(width: AppSpacing.md),
                      _buildLegendDot(const Color(0xFFF59E0B), 'Preparing'),
                      const SizedBox(width: AppSpacing.md),
                      _buildLegendDot(const Color(0xFF3B82F6), 'Occupied'),
                      const SizedBox(width: AppSpacing.md),
                      _buildLegendDot(const Color(0xFFA855F7), 'Billed'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Grid of Tables
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedZoneFilter == 'all' ||
                      _selectedZoneFilter == 'indoor') ...[
                    _buildZoneHeader(
                      icon: Icons.chair_rounded,
                      title: 'Indoor Dining (T-01 to T-12)',
                      count: '12 Tables',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTablesGrid(
                      indoorTables,
                      selectedId,
                      isDark,
                      tableViewModel,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (_selectedZoneFilter == 'all' ||
                      _selectedZoneFilter == 'outdoor') ...[
                    _buildZoneHeader(
                      icon: Icons.deck_rounded,
                      title: 'Outdoor Patio (OD-01 to OD-06)',
                      count: '6 Tables',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTablesGrid(
                      outdoorTables,
                      selectedId,
                      isDark,
                      tableViewModel,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (_selectedZoneFilter == 'all' ||
                      _selectedZoneFilter == 'takeaway') ...[
                    _buildZoneHeader(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Express Takeaway Tokens',
                      count: '4 Tokens',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTablesGrid(
                      takeawayTables,
                      selectedId,
                      isDark,
                      tableViewModel,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneChip(String zoneKey, String label, bool isDark) {
    final isSelected = _selectedZoneFilter == zoneKey;
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() => _selectedZoneFilter = zoneKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isDark
              ? AppColors.darkSurfaceContainer
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildZoneHeader({
    required IconData icon,
    required String title,
    required String count,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title.toUpperCase(),
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
          count,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTablesGrid(
    List<TableModel> tables,
    String selectedId,
    bool isDark,
    TableViewModel tableViewModel,
  ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final isSelected = table.id == selectedId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              tableViewModel.selectTable(table.id);
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        table.id,
                        style: AppTypography.headlineFont(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: table.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        table.seats > 0 ? '${table.seats} Seats' : 'Takeaway',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                      Text(
                        table.status == TableStatus.vacant
                            ? 'Vacant'
                            : table.formattedTotal,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: table.status.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

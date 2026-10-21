import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_typography.dart';

/// Navigation item definition for [NeramBottomNavBar].
class NeramNavItem {
  const NeramNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
}

/// Bottom navigation bar matching the Google Stitch "NERAM POS - Main Dashboard" specification.
/// Features frosted glass blur, 64px height, safe-area inset padding, pill-shaped active tab
/// indicator with 15% radiant amber fill, and tactile haptic feedback.
class NeramBottomNavBar extends StatelessWidget {
  const NeramBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NeramNavItem> items;

  /// Default 3 tabs from Stitch: Table, Stock, Leaves
  static const List<NeramNavItem> defaultItems = [
    NeramNavItem(
      label: 'Table',
      icon: Icons.table_restaurant_outlined,
      activeIcon: Icons.table_restaurant_rounded,
    ),
    NeramNavItem(
      label: 'Stock',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    NeramNavItem(
      label: 'Leaves',
      icon: Icons.event_available_outlined,
      activeIcon: Icons.event_available_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final backgroundColor = isDark
        ? AppColors.darkSurfaceContainerLowest.withValues(alpha: 0.90)
        : Colors.white.withValues(alpha: 0.92);

    final borderColor = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.6)
        : AppColors.lightBorder.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor, width: 1.0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SizedBox(
              height: 64.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = index == currentIndex;
                  final item = items[index];

                  return _buildNavItem(
                    context: context,
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      if (!isSelected) {
                        HapticService.selection();
                        onTap(index);
                      }
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required NeramNavItem item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    if (isSelected) {
      // Active Tab: Pill with horizontal row and radiant amber tint
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.activeIcon ?? item.icon,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  item.label.toUpperCase(),
                  style: AppTypography.headlineFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Inactive Tab: Compact vertical icon + text
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 22, color: inactiveColor),
              const SizedBox(height: 3),
              Text(
                item.label.toUpperCase(),
                style: AppTypography.headlineFont(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: inactiveColor,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

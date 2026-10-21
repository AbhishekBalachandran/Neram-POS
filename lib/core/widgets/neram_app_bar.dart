import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/widgets/neram_logo_badge.dart';

/// Top App Bar matching the Google Stitch "NERAM POS - Main Dashboard" design specification.
/// Features frosted glass blur, dual-tone brand title, uppercase tracked subtitle,
/// 36px rounded logo badge, and interactive drawer menu button.
class NeramAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NeramAppBar({
    super.key,
    this.onMenuPressed,
    this.actions,
    this.showMenuButton = true,
  });

  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;
  final bool showMenuButton;

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    final backgroundColor = isDark
        ? AppColors.darkSurfaceContainerLowest.withValues(alpha: 0.85)
        : AppColors.lightSurface.withValues(alpha: 0.90);

    final borderColor = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.6)
        : AppColors.lightBorder.withValues(alpha: 0.8);

    return Container(
      height: preferredSize.height + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                // Brand Logo & Titles
                Expanded(
                  child: Row(
                    children: [
                      // 36x36 Rounded Logo Badge
                      const NeramLogoBadge(size: 36),
                      const SizedBox(width: AppSpacing.sm + 4),

                      // Two-Tone Brand Title & Tracked Subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'NERAM',
                                  style: AppTypography.headlineFont(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'POS',
                                  style: AppTypography.headlineFont(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              AppConstants.appSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyFont(
                                fontSize: 8.0,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing actions if any
                ...?actions,

                // Drawer Menu Button from Stitch
                if (showMenuButton) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticService.selection();
                        if (onMenuPressed != null) {
                          onMenuPressed!();
                        } else {
                          Scaffold.of(context).openEndDrawer();
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.menu_rounded,
                          size: 24,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

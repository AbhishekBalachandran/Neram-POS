import 'package:flutter/material.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';

/// Reusable decoration patterns, shadows, and card styling.
abstract final class AppDecorations {
  // Soft modern shadows (Zepto / Swiggy style subtle depth)
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> darkElevatedShadow = [
    BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Amber glow for active/selected items
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(color: Color(0x4DFF6B35), blurRadius: 20, offset: Offset(0, 6)),
  ];

  /// Standard card decoration based on brightness.
  static BoxDecoration cardBox(
    BuildContext context, {
    Color? overrideColor,
    BorderRadius? borderRadius,
    bool showBorder = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color:
          overrideColor ??
          (isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurface),
      borderRadius: borderRadius ?? AppSpacing.roundedXl,
      border: showBorder
          ? Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            )
          : null,
      boxShadow: isDark ? darkElevatedShadow : softShadow,
    );
  }
}

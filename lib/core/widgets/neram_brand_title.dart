import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';

/// Reusable branding title widget matching the official NERAM POS identity.
/// Top: NERAM POS in bold primary amber (#F59E0B).
/// Bottom: RESTAURANT & CAFE MANAGEMENT in uppercase with wide letter-spacing.
class NeramBrandTitle extends StatelessWidget {
  const NeramBrandTitle({
    super.key,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleFontSize = 30.0,
    this.subtitleFontSize = 11.5,
    this.spacing = AppSpacing.xs,
  });

  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final double titleFontSize;
  final double subtitleFontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          AppConstants.appShortName,
          textAlign: textAlign,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            height: 1.1,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          AppConstants.appSubtitle,
          textAlign: textAlign,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.8,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

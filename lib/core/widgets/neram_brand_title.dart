import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';

/// Reusable branding title widget matching the Stitch "Amber Hearth POS" identity.
/// Top: NERAM in high-contrast text and POS highlighted in radiant primary amber (#F59E0B).
/// Bottom: RESTAURANT & CAFE MANAGEMENT in uppercase with wide letter-spacing.
class NeramBrandTitle extends StatelessWidget {
  const NeramBrandTitle({
    super.key,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleFontSize = 28.0,
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
        Text.rich(
          TextSpan(
            text: 'NERAM ',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              height: 1.15,
            ),
            children: [
              TextSpan(
                text: 'POS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          textAlign: textAlign,
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
            letterSpacing: 2.5,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

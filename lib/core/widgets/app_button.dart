import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/widgets/animated_pressable.dart';

enum AppButtonVariant { primary, secondary, outline, danger, ghost }

enum AppButtonSize { small, medium, large }

/// Modern, sleek action button designed for high-throughput restaurant POS interactions.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final height = switch (size) {
      AppButtonSize.small => 38.0,
      AppButtonSize.medium => 48.0,
      AppButtonSize.large => 60.0,
    };

    final fontSize = switch (size) {
      AppButtonSize.small => 13.0,
      AppButtonSize.medium => 15.0,
      AppButtonSize.large => 17.0,
    };

    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
    };

    Color backgroundColor;
    Color foregroundColor;
    Border? border;
    Gradient? gradient;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        gradient = _isEnabled ? AppColors.primaryGradient : null;
      case AppButtonVariant.secondary:
        backgroundColor = isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceSubtle;
        foregroundColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        );
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
    }

    if (!_isEnabled) {
      backgroundColor = isDark
          ? AppColors.darkSurfaceSubtle
          : const Color(0xFFE2E8F0);
      foregroundColor = isDark
          ? AppColors.darkTextMuted
          : AppColors.lightTextMuted;
      border = null;
      gradient = null;
    }

    List<BoxShadow>? shadows;
    if (_isEnabled && variant == AppButtonVariant.primary) {
      shadows = const [
        BoxShadow(
          color: Color(0x4DF59E0B),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ];
    }

    final content = AnimatedPressable(
      onTap: _isEnabled
          ? () {
              HapticService.lightImpact();
              onPressed?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            else ...[
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailingIcon!,
              ],
            ],
          ],
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: content);
    }

    return content;
  }
}

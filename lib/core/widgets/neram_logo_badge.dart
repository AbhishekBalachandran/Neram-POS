import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/asset_constants.dart';
import 'package:neram_pos/core/theme/app_colors.dart';

/// Highly stylized brand logo container matching the official design specification.
/// Features a warm charcoal/amber ambient glow in dark mode and an elegant cream/amber
/// gradient in light mode with subtle hairline border and soft depth shadows.
class NeramLogoBadge extends StatelessWidget {
  const NeramLogoBadge({
    super.key,
    this.size = 80.0,
    this.borderRadius,
    this.padding,
  });

  final double size;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.28);
    final effectivePadding = padding ?? EdgeInsets.all(size * 0.17);

    return Container(
      width: size,
      height: size,
      decoration: isDark
          ? BoxDecoration(
              color: const Color(0xFF221D1A),
              gradient: const RadialGradient(
                center: Alignment(0.0, -0.05),
                radius: 0.85,
                colors: [
                  Color(0xFF382D25), // Warm amber ambient center glow
                  Color(0xFF1F1A17), // Deep dark espresso edge
                ],
              ),
              borderRadius: effectiveRadius,
              border: Border.all(
                color: const Color(
                  0xFF5A442C,
                ), // Hairline warm bronze/amber rim
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x45E26E1B), // Soft ambient bottom orange glow
                  blurRadius: 28,
                  spreadRadius: -3,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
              color: const Color(0xFFFFFDF8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFDF8),
                  Color(0xFFFEF3C7), // Delicate warm amber-cream
                ],
              ),
              borderRadius: effectiveRadius,
              border: Border.all(
                color: const Color(0xFFFDE68A), // Soft warm golden border
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24F59E0B), // Gentle golden glow
                  blurRadius: 22,
                  spreadRadius: -2,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
      child: Padding(
        padding: effectivePadding,
        child: Image.asset(
          AssetConstants.appLogo,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.restaurant_rounded,
              color: AppColors.primary,
              size: 36,
            );
          },
        ),
      ),
    );
  }
}

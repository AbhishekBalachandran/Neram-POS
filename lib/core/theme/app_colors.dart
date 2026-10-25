import 'package:flutter/material.dart';

/// Comprehensive color tokens for NERAM POS.
/// Built on the "Amber Hearth POS" Stitch design system with radiant amber (#F59E0B),
/// deep obsidian canvas (#121318), and tiered slate containers.
abstract final class AppColors {
  // Brand Primary & Radiant Amber (Primary: #F59E0B)
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryLight = Color(0xFFFCD34D);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryContainer = Color(0xFFF59E0B);
  static const Color onPrimaryContainer = Color(0xFF78350F);
  static const Color primaryContainerLight = Color(0xFFFEF3C7);
  static const Color primaryContainerDark = Color(0xFF78350F);

  // Amber Reference Tones
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  // Secondary & Accents (Ember & Marigold from Stitch)
  static const Color secondary = Color(0xFFFFB596);
  static const Color secondaryLight = Color(0xFFFFB596);
  static const Color secondaryContainer = Color(0xFFF26411);
  static const Color onSecondary = Color(0xFF581E00);
  static const Color tertiary = Color(0xFFFFB877);
  static const Color tertiaryContainer = Color(0xFFE38100);
  static const Color onTertiary = Color(0xFF4B2700);
  static const Color accent = Color(0xFFFFB877);

  // Functional POS Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorLight = Color(0xFFFFDAD6);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color purple = Color(0xFF8B5CF6);

  // Table State Colors
  static const Color tableAvailable = Color(0xFF10B981);
  static const Color tableOccupied = Color(0xFFF59E0B);
  static const Color tableBilled = Color(0xFF6366F1);
  static const Color tableReserved = Color(0xFF0EA5E9);

  // Light Mode Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF1F5F9);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Obsidian Tiers (from Stitch "Amber Hearth POS")
  static const Color darkBackground = Color(0xFF121318);
  static const Color darkSurface = Color(0xFF121318);
  static const Color darkSurfaceDim = Color(0xFF121318);
  static const Color darkSurfaceBright = Color(0xFF38393E);
  static const Color darkSurfaceContainer = Color(0xFF1E1F24); // Primary Card
  static const Color darkSurfaceContainerLowest = Color(
    0xFF0D0E13,
  ); // Input Field Fill
  static const Color darkSurfaceContainerLow = Color(
    0xFF1A1B20,
  ); // Focused Input
  static const Color darkSurfaceContainerHigh = Color(0xFF292A2F);
  static const Color darkSurfaceContainerHighest = Color(0xFF34343A);
  static const Color darkSurfaceElevated = Color(0xFF292A2F);
  static const Color darkSurfaceSubtle = Color(0xFF1E1F24);
  static const Color darkBorder = Color(0xFF373A43);
  static const Color darkBorderVariant = Color(0xFF594139);
  static const Color darkTextPrimary = Color(0xFFE3E2E8); // on-surface
  static const Color darkTextSecondary = Color(
    0xFFE1BFB5,
  ); // on-surface-variant
  static const Color darkTextMuted = Color(0xFF9E9EA7);

  // Dynamic Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient primaryWarmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1F24), Color(0xFF1A1B20)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB877), Color(0xFFE38100)],
  );
}

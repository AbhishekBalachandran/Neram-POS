import 'package:flutter/material.dart';

/// Comprehensive color tokens for NERAM POS.
/// Primary brand color is #F59E0B (Amber/Gold), combined with modern food-tech palettes.
abstract final class AppColors {
  // Brand Primary & Amber Shades
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryLight = Color(0xFFFBBF24);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryContainerLight = Color(0xFFFEF3C7);
  static const Color primaryContainerDark = Color(0xFF78350F);

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

  // Secondary & Accents
  static const Color secondary = Color(0xFF0F766E); // Teal accent
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color accent = Color(0xFFF97316); // Warm orange accent

  // Functional POS Status Colors
  static const Color success = Color(0xFF10B981); // Emerald - Ready / Settled
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber - Preparing / Pending
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Crimson - Void / Cancelled
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9); // Sky - Takeaway / Online
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color purple = Color(0xFF8B5CF6); // KDS / Kitchen station

  // Table State Colors
  static const Color tableAvailable = Color(0xFF10B981);
  static const Color tableOccupied = Color(0xFFF59E0B);
  static const Color tableBilled = Color(0xFF6366F1);
  static const Color tableReserved = Color(0xFF0EA5E9);

  // Light Mode Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Neutrals (Deep sleek dark palette for POS screens)
  static const Color darkBackground = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF151D2A);
  static const Color darkSurfaceElevated = Color(0xFF1E293B);
  static const Color darkSurfaceSubtle = Color(0xFF243248);
  static const Color darkBorder = Color(0xFF273549);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Dynamic Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient primaryWarmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF151D2A)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
  );
}

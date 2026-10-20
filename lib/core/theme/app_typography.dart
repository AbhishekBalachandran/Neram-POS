import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Standard typography hierarchy for NERAM POS.
/// Built with Inter for ultra-clean legibility across mobile & tablet displays.
abstract final class AppTypography {
  /// Toggle for unit tests or offline environments where online font fetching is disallowed.
  static bool useGoogleFonts = true;

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) {
    if (useGoogleFonts) {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: fontFeatures,
      );
    }
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: fontFeatures,
    );
  }

  static TextTheme textTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      // Display: Hero numbers, grand totals
      displayLarge: _font(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: textColor,
      ),
      displayMedium: _font(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textColor,
      ),
      displaySmall: _font(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: textColor,
      ),

      // Headline: Section headers, table names, sheet titles
      headlineLarge: _font(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textColor,
      ),
      headlineMedium: _font(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: _font(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title: Card titles, item names, dialog headers
      titleLarge: _font(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: _font(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: _font(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body: General descriptions, order notes
      bodyLarge: _font(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: _font(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: _font(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),

      // Label: Badges, button texts, metadata, timestamps
      labelLarge: _font(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: _font(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
      labelSmall: _font(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: mutedColor,
      ),
    );
  }

  /// Specialized receipt/ticket monospace font for thermal printer preview & ticket headers.
  static TextStyle receiptTicket({
    required Color color,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    if (useGoogleFonts) {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// High-impact monetary typography for POS checkouts & totals.
  static TextStyle monetary({
    required Color color,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return _font(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.5,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

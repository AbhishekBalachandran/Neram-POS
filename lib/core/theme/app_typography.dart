import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography hierarchy matching Stitch "Amber Hearth POS":
/// Headlines & Labels: Space Grotesk
/// Body & Input text: Plus Jakarta Sans
abstract final class AppTypography {
  /// Toggle for unit tests or offline environments where online font fetching is disallowed.
  static bool useGoogleFonts = true;

  static TextStyle headlineFont({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    if (useGoogleFonts) {
      return GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle bodyFont({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
  }) {
    if (useGoogleFonts) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontFeatures: fontFeatures,
      );
    }
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: fontFeatures,
    );
  }

  static TextTheme textTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      // Display: Hero numbers, grand totals (Space Grotesk)
      displayLarge: headlineFont(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: textColor,
      ),
      displayMedium: headlineFont(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        color: textColor,
      ),
      displaySmall: headlineFont(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),

      // Headline: Section headers, table names (Space Grotesk)
      headlineLarge: headlineFont(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: headlineFont(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: headlineFont(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title: Card titles, item names (Plus Jakarta Sans)
      titleLarge: bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: bodyFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body: General descriptions, order notes (Plus Jakarta Sans)
      bodyLarge: bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: bodyFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),

      // Label: Badges, button texts, inputs (Space Grotesk)
      labelLarge: headlineFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.04,
        color: textColor,
      ),
      labelMedium: headlineFont(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.03,
        color: mutedColor,
      ),
      labelSmall: headlineFont(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        color: mutedColor,
      ),
    );
  }

  /// High-impact monetary typography for POS checkouts & totals.
  static TextStyle monetary({
    required Color color,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return headlineFont(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.5,
      color: color,
    );
  }
}

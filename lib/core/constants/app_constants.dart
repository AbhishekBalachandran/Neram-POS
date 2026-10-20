/// Core application-wide constants for NERAM POS.
abstract final class AppConstants {
  /// Full formal application title used in title spaces, login headers, and banners.
  static const String appFullName =
      'NERAM POS - Restaurant & Cafe Management System';

  /// Short application name.
  static const String appShortName = 'NERAM POS';

  /// Management subtitle shown under brand name.
  static const String appSubtitle = 'RESTAURANT & CAFE MANAGEMENT';

  /// Application tagline.
  static const String appTagline =
      'Fast, Reliable & Elegant Staff Point of Sale';

  /// App version identifier.
  static const String appVersion = '1.0.0';

  /// Default API timeout in milliseconds.
  static const int defaultConnectTimeout = 30000;
  static const int defaultReceiveTimeout = 30000;

  /// Breakpoints for responsive layouts.
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
}

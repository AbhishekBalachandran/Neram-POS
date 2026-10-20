/// Centralized asset paths for NERAM POS.
abstract final class AssetConstants {
  // Base folders
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';

  // Branding assets
  static const String appLogo = '$_imagesPath/neram_logo.png';
  static const String appLogoWhite = '$_imagesPath/neram_logo_white.png';
  static const String appIcon = '$_imagesPath/app_icon.png';

  // Placeholder and Illustrations
  static const String restaurantIllustration =
      '$_imagesPath/restaurant_illustration.png';
  static const String emptyOrder = '$_imagesPath/empty_orders.png';
  static const String tablePlaceholder = '$_imagesPath/table_placeholder.png';

  // Custom UI Icons
  static const String iconTable = '$_iconsPath/table.png';
  static const String iconKitchen = '$_iconsPath/kitchen.png';
  static const String iconBilling = '$_iconsPath/billing.png';
  static const String iconReports = '$_iconsPath/reports.png';
}

import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';

/// Screen device form factor classification for restaurant POS.
enum DeviceScreenType { mobile, tablet, desktop }

/// Helper for determining form factor and providing responsive screen widgets.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.tabletBreakpoint) {
      return DeviceScreenType.desktop;
    }
    if (width >= AppConstants.mobileBreakpoint) {
      return DeviceScreenType.tablet;
    }
    return DeviceScreenType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.mobileBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);

    if (deviceType == DeviceScreenType.desktop && desktop != null) {
      return desktop!;
    }
    if ((deviceType == DeviceScreenType.tablet ||
            deviceType == DeviceScreenType.desktop) &&
        tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';

class ResponsiveInfo {
  const ResponsiveInfo({
    required this.deviceType,
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
  });

  final ResponsiveType deviceType;
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;

  bool get isMobile => deviceType == ResponsiveType.mobile;
  bool get isTablet => deviceType == ResponsiveType.tablet;
  bool get isDesktop => deviceType == ResponsiveType.desktop;
  bool get isLandscape => orientation == Orientation.landscape;
}

enum ResponsiveType { mobile, tablet, desktop }

/// Widget that simplifies building adaptive views for phones and POS tablets.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final width = mediaQuery.size.width;
        final height = mediaQuery.size.height;
        final orientation = mediaQuery.orientation;

        ResponsiveType type;
        if (width >= AppConstants.tabletBreakpoint) {
          type = ResponsiveType.desktop;
        } else if (width >= AppConstants.mobileBreakpoint) {
          type = ResponsiveType.tablet;
        } else {
          type = ResponsiveType.mobile;
        }

        final info = ResponsiveInfo(
          deviceType: type,
          screenWidth: width,
          screenHeight: height,
          orientation: orientation,
        );

        return builder(context, info);
      },
    );
  }
}

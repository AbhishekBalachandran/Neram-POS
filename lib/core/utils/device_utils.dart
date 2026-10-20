import 'package:flutter/material.dart';

/// Utilities for device metrics, keyboard dismissal, and screen constraints.
abstract final class DeviceUtils {
  /// Dismisses soft keyboard if currently open.
  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Returns total screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Returns total screen height.
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Returns status bar padding.
  static EdgeInsets safePadding(BuildContext context) =>
      MediaQuery.paddingOf(context);
}

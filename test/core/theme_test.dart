import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_theme.dart';
import 'package:neram_pos/core/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.useGoogleFonts = false;

  group('AppTheme Tests', () {
    test('LightTheme defines required primary color and component themes', () {
      final lightTheme = AppTheme.lightTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.primary, AppColors.primary);
      expect(
        lightTheme.colorScheme.primary.toARGB32(),
        AppColors.primary.toARGB32(),
      );
      expect(lightTheme.appBarTheme.backgroundColor, AppColors.lightSurface);
      expect(lightTheme.cardTheme.color, AppColors.lightSurface);
      expect(lightTheme.inputDecorationTheme.filled, true);
    });

    test('DarkTheme defines required primary color and component themes', () {
      final darkTheme = AppTheme.darkTheme;

      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.primary, AppColors.primary);
      expect(
        darkTheme.colorScheme.primary.toARGB32(),
        AppColors.primary.toARGB32(),
      );
      expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(darkTheme.cardTheme.color, AppColors.darkSurfaceContainer);
      expect(darkTheme.inputDecorationTheme.filled, true);
    });
  });
}

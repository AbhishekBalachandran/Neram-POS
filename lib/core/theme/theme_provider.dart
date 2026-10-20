import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that manages dynamic theme switching (Light, Dark, System) and persists state.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required this.prefs}) {
    _loadThemeMode();
  }

  final SharedPreferences prefs;
  static const String _themePrefKey = 'neram_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadThemeMode() {
    final savedMode = prefs.getString(_themePrefKey);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await prefs.setString(_themePrefKey, mode.name);
  }

  Future<void> toggleTheme(BuildContext context) async {
    final currentBrightness = _themeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (_themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);

    if (currentBrightness == Brightness.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

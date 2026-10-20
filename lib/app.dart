import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/theme/app_theme.dart';
import 'package:neram_pos/core/theme/theme_provider.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:provider/provider.dart';

/// Root application widget for NERAM POS.
class NeramPosApp extends StatelessWidget {
  const NeramPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppConstants.appFullName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const LoginView(),
        );
      },
    );
  }
}

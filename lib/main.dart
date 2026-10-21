import 'package:flutter/material.dart';
import 'package:neram_pos/app.dart';
import 'package:neram_pos/core/config/app_config.dart';
import 'package:neram_pos/core/config/env_config.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/network/dio_client.dart';
import 'package:neram_pos/core/security/secure_storage_service.dart';
import 'package:neram_pos/core/security/token_manager.dart';
import 'package:neram_pos/core/theme/theme_provider.dart';
import 'package:neram_pos/data/repositories/auth_repository.dart';
import 'package:neram_pos/viewmodels/app_viewmodel.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/viewmodels/table_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize runtime environment
  AppConfig.instance.initialize(EnvConfig.dev);

  // Initialize persistent preferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize secure storage and token manager
  final secureStorage = SecureStorageService();
  final tokenManager = TokenManager(storageService: secureStorage);

  // Initialize network layer
  final dioClient = DioClient(tokenManager: tokenManager);
  final apiClient = DioApiClient(dioClient: dioClient);

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    tokenManager: tokenManager,
  );

  runApp(
    MultiProvider(
      providers: [
        // Core Services & Repositories
        Provider<SecureStorageService>.value(value: secureStorage),
        Provider<TokenManager>.value(value: tokenManager),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepository),

        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefs),
        ),

        // ViewModels (MVVM state management)
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<AppViewModel>(create: (_) => AppViewModel()),
        ChangeNotifierProvider<TableViewModel>(create: (_) => TableViewModel()),
      ],
      child: const NeramPosApp(),
    ),
  );
}

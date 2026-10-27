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
import 'package:neram_pos/data/repositories/leaves_repository.dart';
import 'package:neram_pos/data/repositories/stock_repository.dart';
import 'package:neram_pos/data/repositories/table_repository.dart';
import 'package:neram_pos/features/printing/repositories/local_order_repository.dart';
import 'package:neram_pos/features/printing/services/hybrid_print_manager.dart';
import 'package:neram_pos/features/printing/services/print_queue.dart';
import 'package:neram_pos/features/printing/services/printer_config_service.dart';
import 'package:neram_pos/features/printing/services/printer_service.dart';
import 'package:neram_pos/features/printing/services/startup_recovery.dart';
import 'package:neram_pos/features/printing/services/sync_service.dart';
import 'package:neram_pos/viewmodels/app_viewmodel.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/viewmodels/leaves_viewmodel.dart';
import 'package:neram_pos/viewmodels/stock_viewmodel.dart';
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
  final tableRepository = TableRepositoryImpl(apiClient: apiClient);
  final stockRepository = StockRepositoryImpl(apiClient: apiClient);
  final leavesRepository = LeavesRepositoryImpl(apiClient: apiClient);

  // Initialize hybrid printing layer
  final localOrderRepository = LocalOrderRepository(prefs: prefs);
  final printerService = const SocketPrinterService();
  final printerConfigService = PrinterConfigService(
    prefs: prefs,
    apiClient: apiClient,
  );
  final syncService = SyncService(
    repository: localOrderRepository,
    apiClient: apiClient,
  )..start();

  final hybridPrintManager = HybridPrintManager(
    repository: localOrderRepository,
    printerService: printerService,
    printerConfigService: printerConfigService,
    syncService: syncService,
  );

  // Run startup recovery (marks in-flight jobs as unknown, re-enqueues pending/failed, syncs)
  await StartupRecovery.recover(
    repository: localOrderRepository,
    printQueue: PrintQueue(
      repository: localOrderRepository,
      printerService: printerService,
      onJobCompleted: () => syncService.triggerSync(),
    ),
    printerConfigService: printerConfigService,
    syncService: syncService,
  );

  runApp(
    MultiProvider(
      providers: [
        // Core Services & Repositories
        Provider<SecureStorageService>.value(value: secureStorage),
        Provider<TokenManager>.value(value: tokenManager),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<TableRepository>.value(value: tableRepository),
        Provider<StockRepository>.value(value: stockRepository),
        Provider<LeavesRepository>.value(value: leavesRepository),
        Provider<LocalOrderRepository>.value(value: localOrderRepository),
        Provider<PrinterConfigService>.value(value: printerConfigService),

        // Hybrid Printing Manager
        ChangeNotifierProvider<HybridPrintManager>.value(
          value: hybridPrintManager,
        ),

        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefs),
        ),

        // ViewModels (MVVM state management)
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<AppViewModel>(create: (_) => AppViewModel()),
        ChangeNotifierProvider<TableViewModel>(
          create: (_) => TableViewModel(repository: tableRepository),
        ),
        ChangeNotifierProvider<LeavesViewModel>(
          create: (_) => LeavesViewModel(repository: leavesRepository),
        ),
        ChangeNotifierProvider<StockViewModel>(
          create: (_) => StockViewModel(repository: stockRepository),
        ),
      ],
      child: const NeramPosApp(),
    ),
  );
}

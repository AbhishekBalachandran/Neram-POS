import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/app.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/theme/theme_provider.dart';
import 'package:neram_pos/core/widgets/neram_app_bar.dart';
import 'package:neram_pos/core/widgets/neram_bottom_nav_bar.dart';
import 'package:neram_pos/core/widgets/neram_logo_badge.dart';
import 'package:neram_pos/data/models/user_model.dart';
import 'package:neram_pos/data/repositories/auth_repository.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:neram_pos/views/home/home_view.dart';
import 'package:neram_pos/views/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldSucceed = true;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().toLowerCase() == 'abhishek' && password == '123456') {
      return UserModel(
        id: 'usr_abhishek_001',
        name: 'Abhishek',
        email: 'abhishek@nerampos.com',
        role: StaffRole.manager,
      );
    }
    if (shouldSucceed) {
      return UserModel(
        id: 'staff_1',
        name: 'Alex Cashier',
        email: 'alex@nerampos.com',
        role: StaffRole.cashier,
      );
    }
    throw Exception('Invalid username or password');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> getProfile() async => null;

  @override
  Future<bool> isAuthenticated() async => false;
}

void main() {
  setUpAll(() {
    AppTypography.useGoogleFonts = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({
    required SharedPreferences prefs,
    required FakeAuthRepository authRepository,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefs),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
      ],
      child: const NeramPosApp(),
    );
  }

  testWidgets(
    'LoginView renders title, username & password fields and validation',
    (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final authRepository = FakeAuthRepository();

      await tester.pumpWidget(
        buildTestApp(prefs: prefs, authRepository: authRepository),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Verify brand title and management subtitle match identity
      expect(find.text(AppConstants.appShortName), findsOneWidget);
      expect(find.text(AppConstants.appSubtitle), findsOneWidget);

      // Verify fields
      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Tap Sign In without filling fields - should trigger validation errors
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'staff01');
      await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
      await tester.pumpAndSettle();

      // Tap Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify success snackbar appears
      expect(find.text('Welcome, Alex Cashier!'), findsOneWidget);
    },
  );

  testWidgets(
    'LoginView sample credentials quick fill and login succeeds for Abhishek',
    (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final authRepository = FakeAuthRepository();

      await tester.pumpWidget(
        buildTestApp(prefs: prefs, authRepository: authRepository),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Tap demo quick fill chip
      final demoFinder = find.textContaining('Demo: abhishek / 123456');
      expect(demoFinder, findsOneWidget);
      await tester.tap(demoFinder);
      await tester.pumpAndSettle();

      // Verify fields filled
      expect(find.text('abhishek'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);

      // Tap Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify welcome snackbar for Abhishek
      expect(find.text('Welcome, Abhishek!'), findsOneWidget);
    },
  );

  testWidgets('LoginView renders dual-pane layout on tablet resolution', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final prefs = await SharedPreferences.getInstance();
    final authRepository = FakeAuthRepository();

    await tester.pumpWidget(
      buildTestApp(prefs: prefs, authRepository: authRepository),
    );
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appShortName), findsOneWidget);
    expect(find.text(AppConstants.appSubtitle), findsOneWidget);
    expect(find.text('Table & Dine-in Management'), findsOneWidget);
    expect(find.text('Realtime Kitchen Display System'), findsOneWidget);
    expect(find.text('Rapid Thermal Billing & Settlement'), findsOneWidget);
  });

  testWidgets('NeramLogoBadge renders properly in light and dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        themeMode: ThemeMode.dark,
        home: Scaffold(body: NeramLogoBadge()),
      ),
    );
    expect(find.byType(NeramLogoBadge), findsOneWidget);
  });

  testWidgets(
    'SplashScreen displays animated logo and transitions to LoginView via JumpingPageRoute',
    (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final authRepository = FakeAuthRepository();

      await tester.pumpWidget(
        buildTestApp(prefs: prefs, authRepository: authRepository),
      );

      // Initial frame presents the SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(NeramLogoBadge), findsOneWidget);

      // Advance past splash timer and jumping transition
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Successfully transitioned to LoginView
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(LoginView), findsOneWidget);
    },
  );

  testWidgets('NeramAppBar renders brand titles, subtitle, and menu action', (
    WidgetTester tester,
  ) async {
    bool menuTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: NeramAppBar(onMenuPressed: () => menuTapped = true),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('NERAM'), findsOneWidget);
    expect(find.text('POS'), findsOneWidget);
    expect(find.text(AppConstants.appSubtitle), findsOneWidget);
    expect(find.byType(NeramLogoBadge), findsOneWidget);

    final menuButton = find.byIcon(Icons.menu_rounded);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    expect(menuTapped, isTrue);
  });

  testWidgets('NeramBottomNavBar switches between Table, Stock, and Leaves', (
    WidgetTester tester,
  ) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              bottomNavigationBar: NeramBottomNavBar(
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() => selectedIndex = index);
                },
              ),
              body: const SizedBox.shrink(),
            ),
          );
        },
      ),
    );

    expect(find.text('TABLE'), findsOneWidget);
    expect(find.text('STOCK'), findsOneWidget);
    expect(find.text('LEAVES'), findsOneWidget);

    // Tap Stock
    await tester.tap(find.text('STOCK'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);

    // Tap Leaves
    await tester.tap(find.text('LEAVES'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 2);
  });

  testWidgets(
    'HomeView renders Stitch Top App Bar, Bottom Nav Bar, and Floor Workspace',
    (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final authRepository = FakeAuthRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(prefs: prefs),
            ),
            ChangeNotifierProvider<AuthViewModel>(
              create: (_) => AuthViewModel(authRepository: authRepository),
            ),
          ],
          child: const MaterialApp(home: HomeView()),
        ),
      );
      await tester.pumpAndSettle();

      // Top App Bar
      expect(find.byType(NeramAppBar), findsOneWidget);
      expect(find.text('NERAM'), findsOneWidget);
      expect(find.text('POS'), findsOneWidget);

      // Floor Workspace Placeholder
      expect(find.text('Floor Workspace'), findsOneWidget);
      expect(
        find.textContaining('Floor grid is clean and ready'),
        findsOneWidget,
      );

      // Bottom Navigation Bar
      expect(find.byType(NeramBottomNavBar), findsOneWidget);
      expect(find.text('TABLE'), findsOneWidget);
      expect(find.text('STOCK'), findsOneWidget);
      expect(find.text('LEAVES'), findsOneWidget);

      // Switch to Stock tab
      await tester.tap(find.text('STOCK'));
      await tester.pumpAndSettle();
      expect(find.text('Stock & Inventory'), findsOneWidget);
    },
  );
}

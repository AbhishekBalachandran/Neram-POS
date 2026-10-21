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
import 'package:neram_pos/viewmodels/leaves_viewmodel.dart';
import 'package:neram_pos/viewmodels/table_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:neram_pos/views/auth/widgets/change_password_dialog.dart';
import 'package:neram_pos/views/home/home_view.dart';
import 'package:neram_pos/views/home/widgets/neram_drawer.dart';
import 'package:neram_pos/views/leaves/leaves_tab_view.dart';
import 'package:neram_pos/views/leaves/widgets/apply_leave_modal.dart';
import 'package:neram_pos/views/profile/profile_view.dart';
import 'package:neram_pos/views/splash/splash_screen.dart';
import 'package:neram_pos/views/table/table_tab_view.dart';
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
        ChangeNotifierProvider<TableViewModel>(create: (_) => TableViewModel()),
        ChangeNotifierProvider<LeavesViewModel>(create: (_) => LeavesViewModel()),
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
    'HomeView renders Stitch Top App Bar, Bottom Nav Bar, and TableTabView',
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
            ChangeNotifierProvider<TableViewModel>(
              create: (_) => TableViewModel(),
            ),
            ChangeNotifierProvider<LeavesViewModel>(
              create: (_) => LeavesViewModel(),
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

      // TableTabView in Tab 0
      expect(find.byType(TableTabView), findsOneWidget);
      expect(find.text('ACTIVE ORDERS'), findsOneWidget);
      expect(find.text('ALL TABLES (12)'), findsOneWidget);
      expect(find.text('POPULAR & RECOMMENDED DISHES'), findsOneWidget);
      expect(find.text('Crispy Corn Pepper Fry'), findsOneWidget);

      // Bottom Navigation Bar
      expect(find.byType(NeramBottomNavBar), findsOneWidget);
      expect(find.text('TABLE'), findsOneWidget);
      expect(find.text('STOCK'), findsOneWidget);
      expect(find.text('LEAVES'), findsOneWidget);

      // Switch to Stock tab
      await tester.tap(find.text('STOCK'));
      await tester.pumpAndSettle();
      expect(find.text('Stock & Inventory'), findsOneWidget);

      // Switch back to Table tab
      await tester.tap(find.text('TABLE'));
      await tester.pumpAndSettle();
      expect(find.byType(TableTabView), findsOneWidget);
    },
  );

  testWidgets('TableTabView opens All Tables sheet and Active Orders dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TableViewModel>(
            create: (_) => TableViewModel(),
          ),
          ChangeNotifierProvider<LeavesViewModel>(
            create: (_) => LeavesViewModel(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TableTabView())),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Swiggy-style AnimatedSearchBar is present with static prefix and rotating hint
    expect(find.text('Search for '), findsOneWidget);
    expect(find.text("'Pizza'"), findsOneWidget);

    // Tap All Tables trigger
    await tester.tap(find.text('ALL TABLES (12)'));
    await tester.pumpAndSettle();

    // Verify bottom sheet appears
    expect(find.text('Indoor Dining Tables'), findsOneWidget);
    expect(find.text('INDOOR DINING (T-01 TO T-12)'), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Indoor Dining Tables'), findsNothing);

    // Tap Active Orders button
    await tester.tap(find.text('ACTIVE ORDERS'));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Active Orders'), findsOneWidget);
    expect(find.text('REALTIME KITCHEN & TABLE ORDERS'), findsOneWidget);

    // Close dialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('REALTIME KITCHEN & TABLE ORDERS'), findsNothing);

    // Verify bottom order tray displays View Order button
    final viewOrderFinder = find.text('View Order');
    expect(viewOrderFinder, findsOneWidget);

    // Tap View Order to open Stitch Animated Order Sheet
    await tester.tap(viewOrderFinder);
    await tester.pumpAndSettle();

    // Verify Animated Order Sheet components
    expect(find.text('Current Order'), findsOneWidget);
    expect(find.text('DINING MODE'), findsOneWidget);
    expect(find.text('INDOOR TABLE'), findsOneWidget);
    expect(find.text('CUSTOMER / GUEST NAME (OPTIONAL)'), findsOneWidget);
    expect(find.text('ORDERED DISHES'), findsOneWidget);
    expect(find.text('Send to Kitchen (KOT)'), findsOneWidget);

    // Confirm & Fire to Kitchen
    await tester.tap(find.text('Send to Kitchen (KOT)'));
    await tester.pumpAndSettle();

    expect(find.text('Current Order'), findsNothing);
  });

  testWidgets('HomeView opens Stitch App Drawer and Change Password Dialog', (
    WidgetTester tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository();
    final authViewModel = AuthViewModel(authRepository: authRepo);
    await authViewModel.login(username: 'abhishek', password: '123456');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(prefs: prefs),
          ),
          ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
          ChangeNotifierProvider<TableViewModel>(
            create: (_) => TableViewModel(),
          ),
          ChangeNotifierProvider<LeavesViewModel>(
            create: (_) => LeavesViewModel(),
          ),
        ],
        child: const MaterialApp(home: HomeView()),
      ),
    );
    await tester.pumpAndSettle();

    // Tap drawer menu button in Top App Bar
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    // Verify Stitch App Drawer components
    expect(find.byType(NeramDrawer), findsOneWidget);
    expect(find.text("TODAY'S ORDERS"), findsOneWidget);
    expect(find.text('TERMINAL CASH'), findsOneWidget);
    expect(find.text('Dark Theme'), findsOneWidget);
    expect(find.text('View Profile & Badges'), findsOneWidget);
    expect(find.text('Change Password / PIN'), findsOneWidget);
    expect(find.text('SIGN OUT & LOCK TERMINAL'), findsOneWidget);

    // Tap Change Password / PIN
    await tester.tap(find.text('Change Password / PIN'));
    await tester.pumpAndSettle();

    // Verify ChangePasswordDialog appears
    expect(find.byType(ChangePasswordDialog), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('PASSWORD SECURITY REQUIREMENTS'), findsOneWidget);
    expect(find.text('0 / 5 MET'), findsOneWidget);

    // Enter a strong password into New Password field
    final newPasswordField = find.widgetWithText(
      TextField,
      'Create strong terminal password',
    );
    await tester.enterText(newPasswordField, 'NeramPass@2026');
    await tester.pump();

    // Verify requirements are updated
    expect(find.text('5 / 5 MET'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);

    // Close dialog via Cancel button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordDialog), findsNothing);

    // Re-open drawer to test View Profile & Badges navigation
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(NeramDrawer), findsOneWidget);

    await tester.tap(find.text('View Profile & Badges'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileView), findsOneWidget);
    expect(find.text('Staff Profile'), findsOneWidget);

    // Pop back to home via back button
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileView), findsNothing);
  });

  testWidgets('LeavesTabView renders shift punch station, metrics gauge, and applies leave', (
    WidgetTester tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository();
    final authViewModel = AuthViewModel(authRepository: authRepo);
    await authViewModel.login(username: 'abhishek', password: '123456');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(prefs: prefs),
          ),
          ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
          ChangeNotifierProvider<TableViewModel>(
            create: (_) => TableViewModel(),
          ),
          ChangeNotifierProvider<LeavesViewModel>(
            create: (_) => LeavesViewModel(),
          ),
        ],
        child: const MaterialApp(home: HomeView()),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Leaves tab in Bottom Navigation Bar (Tab 2)
    await tester.tap(find.text('LEAVES'));
    await tester.pumpAndSettle();

    // Verify LeavesTabView is active
    expect(find.byType(LeavesTabView), findsOneWidget);
    expect(find.text('SHIFT TIMER'), findsOneWidget);
    expect(find.text('Shift & Duty Roster'), findsOneWidget);
    expect(find.text('MONTHLY ATTENDANCE RATE'), findsOneWidget);
    expect(find.text('ELIGIBLE WORK DAYS'), findsOneWidget);
    expect(find.text('LEAVES TAKEN'), findsOneWidget);
    expect(find.text('Leave Audit & Team Log'), findsOneWidget);

    // Verify Check In / Check Out action button
    expect(find.text('Check In'), findsOneWidget);
    await tester.tap(find.text('Check In'));
    await tester.pumpAndSettle();

    // Tap Apply Leave button
    await tester.tap(find.text('Apply Leave'));
    await tester.pumpAndSettle();

    // Verify ApplyLeaveModal opens
    expect(find.byType(ApplyLeaveModal), findsOneWidget);
    expect(find.text('Apply for Leave'), findsOneWidget);
    expect(find.text('Submit Request'), findsOneWidget);

    // Enter absence reason
    final reasonField = find.byType(TextField);
    await tester.enterText(reasonField, 'Family vacation planned');
    await tester.pump();

    // Submit Request
    await tester.tap(find.text('Submit Request'));
    await tester.pumpAndSettle();

    // Modal should close and the new leave application should appear
    expect(find.byType(ApplyLeaveModal), findsNothing);
    expect(find.text('Family vacation planned'), findsOneWidget);
  });

  testWidgets(
    'TableTabView and LeavesTabView render with zero overflow on narrow mobile and tablet screens',
    (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final screenSizes = [
        const Size(320, 568),  // Smallest compact phone (iPhone SE 1st gen)
        const Size(360, 640),  // Standard small budget Android
        const Size(393, 852),  // Modern phone (iPhone 16)
        const Size(768, 1024), // Portrait Tablet (iPad)
        const Size(1024, 768), // Landscape Tablet
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Test TableTabView
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>(
                create: (_) => ThemeProvider(prefs: prefs),
              ),
              ChangeNotifierProvider<TableViewModel>(
                create: (_) => TableViewModel(),
              ),
              ChangeNotifierProvider<LeavesViewModel>(
                create: (_) => LeavesViewModel(),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: TableTabView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Test LeavesTabView
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>(
                create: (_) => ThemeProvider(prefs: prefs),
              ),
              ChangeNotifierProvider<TableViewModel>(
                create: (_) => TableViewModel(),
              ),
              ChangeNotifierProvider<LeavesViewModel>(
                create: (_) => LeavesViewModel(),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: LeavesTabView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Test ApplyLeaveModal on the same screen size
        await tester.tap(find.text('Apply Leave'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(ApplyLeaveModal), findsOneWidget);

        // Close modal
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'ProfileView renders Stitch specifications and handles PIN & HR modals',
    (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final authRepository = FakeAuthRepository();

      tester.view.physicalSize = const Size(768, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(prefs: prefs),
            ),
            ChangeNotifierProvider<AuthViewModel>(
              create: (_) => AuthViewModel(authRepository: authRepository),
            ),
            ChangeNotifierProvider<TableViewModel>(
              create: (_) => TableViewModel(),
            ),
            ChangeNotifierProvider<LeavesViewModel>(
              create: (_) => LeavesViewModel(),
            ),
          ],
          child: const MaterialApp(
            home: ProfileView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify key profile headers & metadata from Stitch
      expect(find.text('Staff Profile'), findsOneWidget);
      expect(find.text('CREDENTIAL & TERMINAL IDENTITY'), findsOneWidget);
      expect(find.text('VIEW-ONLY PROFILE'), findsOneWidget);
      expect(find.text('Account & System Access'), findsOneWidget);

      // Verify Contact Admin / HR modal while at top
      await tester.tap(find.text('Contact Admin / HR'));
      await tester.pumpAndSettle();
      expect(find.text('Contact Store Administration'), findsOneWidget);

      // Close Contact Admin modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Contact Store Administration'), findsNothing);

      // Verify Update PIN modal
      await tester.tap(find.text('Update PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Update Quick PIN'), findsOneWidget);
      expect(find.text('NEW 4-DIGIT SPEED PIN'), findsOneWidget);

      // Cancel Update PIN modal
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Update Quick PIN'), findsNothing);

      // Scroll down and verify remaining sections
      await tester.scrollUntilVisible(find.text('Personal & Employment Details'), 200);
      expect(find.text('Personal & Employment Details'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Bank Account & Payout Details'), 200);
      expect(find.text('Bank Account & Payout Details'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Log Out of Terminal'), 200);
      expect(find.text('Log Out of Terminal'), findsOneWidget);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/app.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/theme/theme_provider.dart';
import 'package:neram_pos/core/widgets/neram_logo_badge.dart';
import 'package:neram_pos/data/models/user_model.dart';
import 'package:neram_pos/data/repositories/auth_repository.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldSucceed = true;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
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
      await tester.pumpAndSettle();

      // Verify brand title and management subtitle match identity
      expect(find.text(AppConstants.appShortName), findsOneWidget);
      expect(find.text(AppConstants.appSubtitle), findsOneWidget);

      // Verify fields
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
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
}

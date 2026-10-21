import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/theme/theme_provider.dart';
import 'package:neram_pos/core/utils/jumping_page_route.dart';
import 'package:neram_pos/core/widgets/neram_app_bar.dart';
import 'package:neram_pos/core/widgets/neram_bottom_nav_bar.dart';
import 'package:neram_pos/data/models/user_model.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:provider/provider.dart';

/// Main Dashboard view matching the Google Stitch "NERAM POS - Main Dashboard" specification.
/// Features the frosted glass top app bar, bottom navigation bar (Table, Stock, Leaves),
/// and responsive workspace views.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    HapticService.selection();
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      JumpingPageRoute(page: const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: NeramAppBar(
        onMenuPressed: () {
          Scaffold.of(context).openEndDrawer();
        },
      ),
      endDrawer: _buildStaffDrawer(context, isDark, user),
      body: SafeArea(
        top: false,
        bottom: false,
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            // Tab 0: Floor Workspace (from Stitch)
            _buildWorkspacePlaceholder(
              isDark: isDark,
              icon: Icons.table_restaurant_rounded,
              title: 'Floor Workspace',
              description:
                  'Floor grid is clean and ready. Tap into floor management or select a table to begin.',
            ),

            // Tab 1: Stock Workspace
            _buildWorkspacePlaceholder(
              isDark: isDark,
              icon: Icons.inventory_2_rounded,
              title: 'Stock & Inventory',
              description:
                  'Realtime stock status, ingredient consumption, and warehouse replenishment.',
            ),

            // Tab 2: Leaves & Attendance
            _buildWorkspacePlaceholder(
              isDark: isDark,
              icon: Icons.event_available_rounded,
              title: 'Leaves & Roster',
              description:
                  'Staff attendance, shift schedules, and leave approval management.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: NeramBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabChanged,
      ),
    );
  }

  /// Workspace Placeholder card matching the Stitch Main Dashboard HTML spec
  Widget _buildWorkspacePlaceholder({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xxxl,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainer.withValues(alpha: 0.60)
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 64x64 rounded icon container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainerHigh
                        : AppColors.lightSurfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Workspace title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Staff side drawer for quick actions (Profile, Theme Toggle, Sign Out)
  Widget _buildStaffDrawer(BuildContext context, bool isDark, UserModel? user) {
    final themeProvider = context.watch<ThemeProvider>();

    return Drawer(
      backgroundColor: isDark
          ? AppColors.darkSurfaceContainer
          : AppColors.lightSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Staff Member',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          user != null ? user.role.name.toUpperCase() : 'STAFF',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Navigation Options
            ListTile(
              leading: const Icon(Icons.table_restaurant_rounded),
              title: const Text('Table Management'),
              selected: _currentTabIndex == 0,
              onTap: () {
                Navigator.of(context).pop();
                _onTabChanged(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_rounded),
              title: const Text('Stock & Inventory'),
              selected: _currentTabIndex == 1,
              onTap: () {
                Navigator.of(context).pop();
                _onTabChanged(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available_rounded),
              title: const Text('Leaves & Shifts'),
              selected: _currentTabIndex == 2,
              onTap: () {
                Navigator.of(context).pop();
                _onTabChanged(2);
              },
            ),

            const Divider(height: 1),

            // Theme Toggle
            SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (_) {
                themeProvider.toggleTheme(context);
              },
            ),

            const Spacer(),
            const Divider(height: 1),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _handleLogout,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

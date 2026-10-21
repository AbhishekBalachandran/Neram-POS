import 'package:flutter/material.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/widgets/neram_app_bar.dart';
import 'package:neram_pos/core/widgets/neram_bottom_nav_bar.dart';
import 'package:neram_pos/views/home/widgets/neram_drawer.dart';
import 'package:neram_pos/views/leaves/leaves_tab_view.dart';
import 'package:neram_pos/views/table/table_tab_view.dart';

/// Main Dashboard view matching the Google Stitch "NERAM POS - Main Dashboard" specification
/// and "NERAM POS - App Drawer" specification.
/// Features the frosted glass top app bar, bottom navigation bar (Table, Stock, Leaves),
/// comprehensive staff drawer, and responsive workspace views.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: NeramAppBar(
        onMenuPressed: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: NeramDrawer(onTabSelected: _onTabChanged),
      body: SafeArea(
        top: false,
        bottom: false,
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            // Tab 0: Table & Active Orders Workspace (from Stitch)
            const TableTabView(),

            // Tab 1: Stock Workspace
            _buildWorkspacePlaceholder(
              isDark: isDark,
              icon: Icons.inventory_2_rounded,
              title: 'Stock & Inventory',
              description:
                  'Realtime stock status, ingredient consumption, and warehouse replenishment.',
            ),

            // Tab 2: Leaves & Attendance (from Stitch)
            const LeavesTabView(),
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
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  title,
                  style: AppTypography.headlineFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
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
}

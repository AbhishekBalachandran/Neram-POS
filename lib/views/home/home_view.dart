import 'package:flutter/material.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/widgets/neram_app_bar.dart';
import 'package:neram_pos/core/widgets/neram_bottom_nav_bar.dart';
import 'package:neram_pos/views/home/widgets/neram_drawer.dart';
import 'package:neram_pos/views/leaves/leaves_tab_view.dart';
import 'package:neram_pos/views/stock/stock_tab_view.dart';
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

            // Tab 1: Stock & Inventory Management (from Stitch)
            const StockTabView(),

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
}

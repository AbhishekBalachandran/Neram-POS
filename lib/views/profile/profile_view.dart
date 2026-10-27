import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/utils/jumping_page_route.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:provider/provider.dart';

/// Staff Profile View displaying:
/// - Staff Identity with Staff Name and Badges (Employee, Active/Inactive, Waiter)
/// - Account section (key-value)
/// - Employment section (key-value)
/// - Bank & Payout section (key-value)
/// - Safe logout action
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  /// Allows disabling infinite repeating animations in widget test environments.
  static bool enableAnimations = true;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  bool _isActive = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (ProfileView.enableAnimations) {
      _pulseController.repeat();
    }
    _pulseScale = Tween<double>(begin: 1.0, end: 2.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.75, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    HapticService.selection();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label copied to clipboard',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1F24),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x33F59E0B)),
        ),
      ),
    );
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

    // Default to 'Abhishek' as requested by the user, or user's first name
    final staffName = (user != null && user.name.isNotEmpty)
        ? user.name.split(' ').first
        : 'Abhishek';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () {
            HapticService.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Staff Profile',
          style: AppTypography.headlineFont(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              children: [
                // 1. PRIMARY IDENTITY CARD (Staff Name & Badges)
                _buildIdentityCard(isDark, staffName),
                const SizedBox(height: AppSpacing.md),

                // 2. ACCOUNT SECTION
                _buildAccountSection(isDark, staffName),
                const SizedBox(height: AppSpacing.md),

                // 3. EMPLOYMENT SECTION
                _buildEmploymentSection(isDark),
                const SizedBox(height: AppSpacing.md),

                // 4. BANK & PAYOUT SECTION
                _buildBankPayoutSection(isDark, staffName),
                const SizedBox(height: AppSpacing.lg),

                // 5. LOGOUT BUTTON
                _buildLogoutButton(isDark),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. PRIMARY IDENTITY CARD
  // ---------------------------------------------------------------------------
  Widget _buildIdentityCard(bool isDark, String staffName) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with Pulsing Active Beacon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      staffName.isNotEmpty ? staffName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -3,
                    right: -3,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          if (_isActive)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseScale.value,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(
                                        alpha: _pulseOpacity.value,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: _isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkSurfaceContainer
                                    : AppColors.lightSurface,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isActive
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF94A3B8))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Staff Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staffName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineFont(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Staff Member • Neram POS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Badges: Employee badge, Active or Inactive badge, Waiter badge
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Employee badge
              _buildBadge(
                label: 'Employee',
                icon: Icons.badge_rounded,
                textColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0x1A6366F1),
                borderColor: const Color(0x336366F1),
              ),

              // Active or Inactive badge (clickable to toggle state)
              GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() {
                    _isActive = !_isActive;
                  });
                  context.read<AuthViewModel>().updateStatus(isActive: _isActive);
                },
                child: _buildBadge(
                  label: _isActive ? 'Active' : 'Inactive',
                  icon: _isActive
                      ? Icons.check_circle_rounded
                      : Icons.pause_circle_filled_rounded,
                  textColor: _isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                  backgroundColor: _isActive
                      ? const Color(0x1A10B981)
                      : const Color(0x1A94A3B8),
                  borderColor: _isActive
                      ? const Color(0x3310B981)
                      : const Color(0x3394A3B8),
                ),
              ),

              // Waiter badge
              _buildBadge(
                label: 'Waiter',
                icon: Icons.room_service_rounded,
                textColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                borderColor: AppColors.primary.withValues(alpha: 0.30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. ACCOUNT SECTION
  // ---------------------------------------------------------------------------
  Widget _buildAccountSection(bool isDark, String staffName) {
    return _buildSectionCard(
      title: 'Account',
      icon: Icons.manage_accounts_rounded,
      isDark: isDark,
      children: [
        _buildKeyValueRow('Username', staffName, isDark),
        _buildDivider(isDark),
        _buildKeyValueRow('Role', 'Employee', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Table orders & POS',
          'Allowed',
          isDark,
          statusColor: const Color(0xFF10B981),
        ),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Inventory',
          'Allowed',
          isDark,
          statusColor: const Color(0xFF10B981),
        ),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Print bill',
          'Restricted',
          isDark,
          statusColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. EMPLOYMENT SECTION
  // ---------------------------------------------------------------------------
  Widget _buildEmploymentSection(bool isDark) {
    return _buildSectionCard(
      title: 'Employment',
      icon: Icons.work_rounded,
      isDark: isDark,
      children: [
        _buildKeyValueRow('Full name', 'Abhishek B Ambady', isDark, isBold: true),
        _buildDivider(isDark),
        _buildKeyValueRow('Designation', 'Waiter', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Phone',
          '9876543210',
          isDark,
          onCopy: () => _copyToClipboard('9876543210', 'Phone number'),
        ),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Email',
          'abc@gmail.com',
          isDark,
          onCopy: () => _copyToClipboard('abc@gmail.com', 'Email address'),
        ),
        _buildDivider(isDark),
        _buildKeyValueRow('Department', 'Dining & Service', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow('Joined', '15 Jan 2023', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow('Basic salary', '20000', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow('Leave quota', '12 paid / 12 casual days per year', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Address',
          '12/482 Neram Lane, Panampilly Nagar, Kochi, Kerala 682036',
          isDark,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. BANK & PAYOUT SECTION
  // ---------------------------------------------------------------------------
  Widget _buildBankPayoutSection(bool isDark, String staffName) {
    return _buildSectionCard(
      title: 'Bank & Payout',
      icon: Icons.account_balance_rounded,
      isDark: isDark,
      children: [
        _buildKeyValueRow('Account holder', staffName, isDark, isBold: true),
        _buildDivider(isDark),
        _buildKeyValueRow('Bank', 'Federal Bank', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'Account number',
          '982374982739',
          isDark,
          onCopy: () => _copyToClipboard('982374982739', 'Account number'),
        ),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'IFSC',
          'AL432892',
          isDark,
          onCopy: () => _copyToClipboard('AL432892', 'IFSC code'),
        ),
        _buildDivider(isDark),
        _buildKeyValueRow('Branch', 'Kochi', isDark),
        _buildDivider(isDark),
        _buildKeyValueRow(
          'UPI ID',
          '4894938@icici',
          isDark,
          onCopy: () => _copyToClipboard('4894938@icici', 'UPI ID'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. LOGOUT BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: BorderSide(
            color: const Color(0xFFEF4444).withValues(alpha: 0.4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Log Out of Terminal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER COMPONENTS
  // ---------------------------------------------------------------------------
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 14, AppSpacing.md, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.headlineFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          // Section Card Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueRow(
    String keyLabel,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? statusColor,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Key Label
          Flexible(
            flex: 2,
            child: Text(
              keyLabel,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right: Value (with optional status pill or copy action)
          Flexible(
            flex: 3,
            child: statusColor != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  )
                : onCopy != null
                    ? InkWell(
                        onTap: onCopy,
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                value,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ],
                        ),
                      )
                    : Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
            .withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

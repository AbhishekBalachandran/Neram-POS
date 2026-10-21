import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/utils/jumping_page_route.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:neram_pos/views/auth/widgets/change_password_dialog.dart';
import 'package:provider/provider.dart';

/// Staff Profile View matching the Google Stitch "NERAM POS - View Profile" specification
/// (screens `1811f39bd73947a6ab817feb1e614254` and `bd31b28b80da4441843fe52c02655829`).
///
/// Features:
/// - Top App Bar with brand logo & drawer trigger
/// - Internal Navigation Sub-header with Back button & Quick Lock Terminal action
/// - Primary Identity Card with avatar beacon, active status badge, and employee ID
/// - View-Only Profile notice banner with HR / Admin contact action
/// - Account & System Access card (Operator username with copy, terminal grants, system entitlements, and PIN action)
/// - Personal & Employment Details card (Salary, joining date, leaves quota, address)
/// - Bank Account & Payout Details card (Masked account number, IFSC code & UPI ID with copy actions)
/// - Terminal Log Out action button and version engine tag
/// - Interactive Update Quick PIN modal dialog
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  /// Allows disabling infinite repeating animations in widget test environments.
  static bool enableAnimations = true;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
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
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label copied to clipboard',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1F24),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x33FF6B35)),
        ),
      ),
    );
  }

  void _showQuickLockDialog() {
    HapticService.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Lock Terminal?',
                style: AppTypography.headlineFont(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Your active shift session will remain safe. You can quickly re-authenticate with your PIN.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleLogout();
            },
            child: const Text('Lock Terminal', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showContactAdminModal() {
    HapticService.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurfaceContainer : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Store Administration',
                        style: AppTypography.headlineFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Profile & Payroll Support',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildContactItem(
                isDark: isDark,
                icon: Icons.person_rounded,
                title: 'Chef Julian V. (Store Manager)',
                subtitle: '+1 (555) 014-9912 • Floor Admin Desk',
                onCopy: () => _copyToClipboard('+15550149912', 'Store Manager phone'),
              ),
              const SizedBox(height: 8),
              _buildContactItem(
                isDark: isDark,
                icon: Icons.mail_rounded,
                title: 'People Operations & HR Desk',
                subtitle: 'hr@nerampos.internal • Response in 2-4 hrs',
                onCopy: () => _copyToClipboard('hr@nerampos.internal', 'HR Email'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceSubtle,
                    foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, size: 16),
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  void _showUpdateQuickPinModal() {
    HapticService.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPasswordController = TextEditingController();
    final newPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Update Quick PIN',
                  style: AppTypography.headlineFont(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your current master password to change your 4-digit POS register speed PIN.',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CURRENT PASSWORD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '••••••••',
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceSubtle,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'NEW 4-DIGIT SPEED PIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.headlineFont(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceSubtle,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.security_rounded, size: 14, color: AppColors.primary),
                label: const Text(
                  'Change full master password',
                  style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ChangePasswordDialog.show(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (newPinController.text.length != 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid 4-digit PIN'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop();
                    HapticService.success();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Quick Speed PIN updated successfully!'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
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

    final userName = user?.name ?? 'Alex Morgan';
    final userRole = user != null
        ? user.role.name.toUpperCase()
        : 'HEAD BARISTA • SHIFT FLOOR LEAD';
    final userEmail = user?.email ?? 'alex.morgan@nerampos.internal';
    final userPhone = user?.phone ?? '+1 (555) 019-2834';
    final userInitials = userName.isNotEmpty
        ? userName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : 'AM';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        top: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl + 16,
              ),
              children: [
                // 1. SUB-HEADER / CONTEXT BAR
                _buildSubHeader(isDark),
                const SizedBox(height: AppSpacing.sm),

                // 2. PRIMARY IDENTITY CARD
                _buildPrimaryIdentityCard(
                  isDark: isDark,
                  name: userName,
                  initials: userInitials,
                  role: userRole,
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. PROMINENT WARNING NOTICE BANNER (VIEW-ONLY PROFILE)
                _buildViewOnlyBanner(isDark),
                const SizedBox(height: AppSpacing.lg),

                // 4. ACCOUNT & SYSTEM ACCESS SECTION
                _buildAccountAccessSection(isDark, userName),
                const SizedBox(height: AppSpacing.lg),

                // 5. SECTION A: PERSONAL & EMPLOYMENT DETAILS
                _buildPersonalEmploymentSection(
                  isDark: isDark,
                  name: userName,
                  email: userEmail,
                  phone: userPhone,
                  role: userRole,
                ),
                const SizedBox(height: AppSpacing.lg),

                // 6. SECTION B: BANK ACCOUNT & PAYOUT DETAILS
                _buildBankAccountSection(isDark, userName),
                const SizedBox(height: AppSpacing.xl),

                // 7. SIGN OUT FOOTNOTE & VERSION ENGINE TAG
                _buildSignOutFootnote(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SUB-HEADER / CONTEXT BAR
  // ---------------------------------------------------------------------------
  Widget _buildSubHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticService.selection();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainerHigh
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Profile',
                    style: AppTypography.headlineFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'CREDENTIAL & TERMINAL IDENTITY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showQuickLockDialog,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  size: 20,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. PRIMARY IDENTITY CARD
  // ---------------------------------------------------------------------------
  Widget _buildPrimaryIdentityCard({
    required bool isDark,
    required String name,
    required String initials,
    required String role,
  }) {
    final containerColor = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Warm Hearth Ambient Glow in top right
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Active Beacon
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE85D04), Color(0xFFFF6B35)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33FF6B35),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: AppTypography.headlineFont(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -3,
                          bottom: -3,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Pulsing Radar Ring (animate-ping)
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
                                // Solid Central Dot
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: containerColor,
                                      width: 2.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x5510B981),
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
                    const SizedBox(width: AppSpacing.md),

                    // Staff Information & Active Pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTypography.headlineFont(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.tertiary.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceContainerHighest
                                      : AppColors.lightSurfaceSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'EMP-8829',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Since Jan 2024',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. PROMINENT WARNING NOTICE BANNER (VIEW-ONLY PROFILE)
  // ---------------------------------------------------------------------------
  Widget _buildViewOnlyBanner(bool isDark) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Stack(
        children: [
          // Left Orange Accent Indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: AppColors.primary),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'VIEW-ONLY PROFILE',
                            style: AppTypography.headlineFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceContainerLowest
                                  : AppColors.lightSurfaceSubtle,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Text(
                              'LOCKED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Personal details, operational credentials, and payroll records can only be updated by restaurant administration or store managers.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showContactAdminModal,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Contact Admin / HR',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ACCOUNT & SYSTEM ACCESS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildAccountAccessSection(bool isDark, String rawName) {
    final cleanUsername = rawName
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '.')
        .replaceAll(RegExp(r'[^a-z0-9.]'), '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Account & System Access',
                    style: AppTypography.headlineFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerHighest
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tier 2 POS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Section Container
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username Row with Copy
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerLow
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPERATOR USERNAME',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cleanUsername,
                                  style: AppTypography.headlineFont(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                size: 15,
                                color: AppColors.tertiary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _copyToClipboard(cleanUsername, 'Username'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceContainerHighest
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.content_copy_rounded, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Role Authority
              Text(
                'ROLE AUTHORITY',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Floor Captain / POS Operator',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Level 2',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Terminal Grants Chips
              Text(
                'TERMINAL GRANTS',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildGrantChip(isDark, Icons.shopping_cart_rounded, 'Orders & Kitchen'),
                  _buildGrantChip(isDark, Icons.table_restaurant_rounded, 'Table Allocation'),
                  _buildGrantChip(isDark, Icons.payments_rounded, 'Cash Register'),
                  _buildGrantChip(isDark, Icons.event_available_rounded, 'Staff Leaves'),
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.lightBorder,
              ),
              const SizedBox(height: 12),

              // System Access Entitlements
              Text(
                'SYSTEM ACCESS ENTITLEMENTS',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Entitlement 1: POS Ordering Access
              _buildEntitlementRow(
                isDark: isDark,
                icon: Icons.check_circle_rounded,
                iconBg: const Color(0x2210B981),
                iconColor: const Color(0xFF10B981),
                title: 'POS Ordering Access',
                subtitle: 'Terminal Order & Kitchen Dispatch',
                badgeText: 'Allowed',
                badgeColor: const Color(0xFF10B981),
                badgeBg: const Color(0x2210B981),
              ),
              const SizedBox(height: 8),

              // Entitlement 2: Inventory Management Access
              _buildEntitlementRow(
                isDark: isDark,
                icon: Icons.block_rounded,
                iconBg: AppColors.errorContainer.withValues(alpha: 0.25),
                iconColor: AppColors.error,
                title: 'Inventory Management Access',
                subtitle: 'Stock Control & Purchasing Order',
                badgeText: 'Denied',
                badgeColor: AppColors.error,
                badgeBg: AppColors.errorContainer.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 14),

              // Last Terminal Sync / Shift Duration (from Stitch bd31)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerLow
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LAST TERMINAL SYNC',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Today, 06:20 AM',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SHIFT DURATION',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          '4h 42m elapsed',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Security / PIN Action Row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerLowest
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.6)
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.password_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PIN & Password',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Configured & Active',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _showUpdateQuickPinModal,
                      icon: const Icon(Icons.key_rounded, size: 14),
                      label: const Text(
                        'Update PIN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrantChip(bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntitlementRow({
    required bool isDark,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLow
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. SECTION A: PERSONAL & EMPLOYMENT DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildPersonalEmploymentSection({
    required bool isDark,
    required String name,
    required String email,
    required String phone,
    required String role,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.badge_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Personal & Employment Details',
                    style: AppTypography.headlineFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.lock_rounded,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Detail Rows Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow(isDark, Icons.person_rounded, 'Full Name', name),
              _buildDetailRow(
                isDark,
                Icons.workspace_premium_rounded,
                'Designation',
                role,
                highlightValue: true,
              ),
              _buildDetailRow(isDark, Icons.call_rounded, 'Phone Contact', phone),
              _buildDetailRow(isDark, Icons.mail_rounded, 'Email Address', email),
              _buildDetailRow(isDark, Icons.store_rounded, 'Department', 'Food & Beverage'),
              _buildDetailRow(isDark, Icons.event_rounded, 'Date of Joining', '15 Jan 2024'),
              _buildDetailRow(
                isDark,
                Icons.payments_rounded,
                'Monthly Basic Salary',
                '₹3,850.00 / mo',
                accentValue: true,
              ),
              _buildDetailRow(
                isDark,
                Icons.event_available_rounded,
                'Annual Leaves Quota',
                '18 Days (12 Paid / 6 Casual)',
              ),
              _buildDetailRow(
                isDark,
                Icons.home_rounded,
                'Residential Address',
                '742 Evergreen Terrace, Apt 4B, Metro City',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    bool isDark,
    IconData icon,
    String label,
    String value, {
    bool highlightValue = false,
    bool accentValue = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : AppColors.lightBorder,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: (highlightValue || accentValue)
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: highlightValue
                    ? AppColors.primary
                    : accentValue
                    ? AppColors.tertiary
                    : isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. SECTION B: BANK ACCOUNT & PAYOUT DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildBankAccountSection(bool isDark, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bank Account & Payout Details',
                    style: AppTypography.headlineFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerHighest
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Bank Account Container
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Holder Name
              _buildBankFieldCard(
                isDark: isDark,
                label: 'ACCOUNT HOLDER NAME',
                value: name,
                trailing: Icon(
                  Icons.lock_rounded,
                  size: 15,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // Bank Name & Bank Branch
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 380;
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildBankFieldCard(
                            isDark: isDark,
                            label: 'BANK NAME',
                            value: 'First Metro Commercial Bank',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildBankFieldCard(
                            isDark: isDark,
                            label: 'BANK BRANCH',
                            value: 'Downtown Financial Plaza',
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildBankFieldCard(
                          isDark: isDark,
                          label: 'BANK NAME',
                          value: 'First Metro Commercial Bank',
                        ),
                        const SizedBox(height: 10),
                        _buildBankFieldCard(
                          isDark: isDark,
                          label: 'BANK BRANCH',
                          value: 'Downtown Financial Plaza',
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 10),

              // Account Number with Lock
              _buildBankFieldCard(
                isDark: isDark,
                label: 'ACCOUNT NUMBER',
                value: '•••• •••• 8842 1904',
                trailing: Icon(
                  Icons.lock_rounded,
                  size: 15,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // IFSC Code & UPI ID (with copy triggers)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 380;
                  final upiClean = '${name.toLowerCase().replaceAll(' ', '')}@okposbank';

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildBankCopyCard(
                            isDark: isDark,
                            label: 'IFSC CODE',
                            value: 'FMCB0004921',
                            onCopy: () => _copyToClipboard('FMCB0004921', 'IFSC Code'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildBankCopyCard(
                            isDark: isDark,
                            label: 'UPI ID',
                            value: upiClean,
                            onCopy: () => _copyToClipboard(upiClean, 'UPI ID'),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildBankCopyCard(
                          isDark: isDark,
                          label: 'IFSC CODE',
                          value: 'FMCB0004921',
                          onCopy: () => _copyToClipboard('FMCB0004921', 'IFSC Code'),
                        ),
                        const SizedBox(height: 10),
                        _buildBankCopyCard(
                          isDark: isDark,
                          label: 'UPI ID',
                          value: upiClean,
                          onCopy: () => _copyToClipboard(upiClean, 'UPI ID'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankFieldCard({
    required bool isDark,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLow
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildBankCopyCard({
    required bool isDark,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLow
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerHighest
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.content_copy_rounded, size: 12),
                    SizedBox(width: 3),
                    Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. SIGN OUT FOOTNOTE & VERSION ENGINE TAG
  // ---------------------------------------------------------------------------
  Widget _buildSignOutFootnote(bool isDark) {
    return Column(
      children: [
        // Log Out of Terminal Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.lightSurface,
              foregroundColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            onPressed: () {
              HapticService.selection();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: isDark ? AppColors.darkSurfaceContainer : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Sign Out of Terminal?',
                          style: AppTypography.headlineFont(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Are you sure you want to end your terminal session? Any unsaved orders will be preserved.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _handleLogout();
                      },
                      child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
              color: AppColors.error,
            ),
            label: const Text(
              'Log Out of Terminal',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Terminal Engine Tag
        Text(
          'NERAM POS v3.4.1 • Terminal Engine Active',
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

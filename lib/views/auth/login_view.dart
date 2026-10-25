import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/app_constants.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_decorations.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/utils/device_utils.dart';
import 'package:neram_pos/core/utils/jumping_page_route.dart';
import 'package:neram_pos/core/widgets/app_button.dart';
import 'package:neram_pos/core/widgets/app_text_field.dart';
import 'package:neram_pos/core/widgets/neram_brand_title.dart';
import 'package:neram_pos/core/widgets/neram_logo_badge.dart';
import 'package:neram_pos/core/widgets/responsive_builder.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/home/home_view.dart';
import 'package:provider/provider.dart';

/// Staff authentication screen updated to match the Stitch "Amber Hearth POS" design system.
/// Implements radiant amber (#F59E0B), obsidian card surfaces (#1E1F24 / #0D0E13),
/// Space Grotesk / Plus Jakarta Sans typography, and floating toast notifications.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    DeviceUtils.hideKeyboard(context);
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticService.error();
      return;
    }

    HapticService.mediumImpact();
    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (success) {
      HapticService.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDark
              ? AppColors.darkSurfaceContainerHighest
              : AppColors.lightSurface,
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Welcome, ${authViewModel.currentUser?.name ?? "Staff"}!',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(JumpingPageRoute(page: const HomeView()));
    } else {
      HapticService.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => DeviceUtils.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Ambient atmospheric glow backing from Stitch design
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.55),
                      radius: 0.95,
                      colors: isDark
                          ? const [
                              Color(0x24F59E0B), // Subtle amber aura
                              Colors.transparent,
                            ]
                          : const [Color(0x15F59E0B), Colors.transparent],
                    ),
                  ),
                ),
              ),

              // Responsive Screen Layout
              ResponsiveBuilder(
                builder: (context, info) {
                  if (info.screenWidth >= 860) {
                    return _buildTabletLayout(context, isDark);
                  }
                  return _buildMobileLayout(context, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABLET / DESKTOP DUAL-PANE LAYOUT
  // ---------------------------------------------------------------------------
  Widget _buildTabletLayout(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: AppDecorations.cardBox(
                  context,
                  borderRadius: AppSpacing.roundedXl,
                ),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Brand Showcase Banner
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1E1F24),
                                      Color(0xFF121318),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFFDF8),
                                      Color(0xFFFEF3C7),
                                    ],
                                  ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLogoContainer(size: 88),
                              const SizedBox(height: AppSpacing.xl),
                              const NeramBrandTitle(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                textAlign: TextAlign.start,
                                titleFontSize: 32.0,
                                subtitleFontSize: 12.0,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                AppConstants.appTagline,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              _buildFeatureBadge(
                                icon: Icons.table_restaurant_rounded,
                                label: 'Table & Dine-in Management',
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildFeatureBadge(
                                icon: Icons.kitchen_rounded,
                                label: 'Realtime Kitchen Display System',
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildFeatureBadge(
                                icon: Icons.receipt_long_rounded,
                                label: 'Rapid Thermal Billing & Settlement',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vertical Divider
                      Container(
                        width: 1,
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),

                      // Right Form Panel
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxl,
                            vertical: AppSpacing.xxxl,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: _buildLoginForm(context, isDark),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE SINGLE-COLUMN LAYOUT
  // ---------------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Atmospheric Brand Badge Enclosure
                  _buildLogoContainer(size: 88),
                  const SizedBox(height: AppSpacing.lg),

                  // Brand Title & Tagline
                  const NeramBrandTitle(
                    titleFontSize: 28.0,
                    subtitleFontSize: 11.5,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Staff Access',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Primary Interactive Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: AppDecorations.cardBox(context),
                    child: _buildLoginForm(context, isDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIN FORM COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildLoginForm(BuildContext context, bool isDark) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error banner if any
              if (authViewModel.hasError &&
                  authViewModel.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF450A0A)
                        : AppColors.onErrorContainer,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          authViewModel.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF991B1B),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Username Field (from Stitch)
              AppTextField(
                controller: _usernameController,
                label: 'Username',
                hintText: 'Enter username',
                prefixIcon: Icons.account_circle,
                showClearButton: true,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Password Field (from Stitch)
              AppTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: 'Password',
                hintText: 'Enter password',
                prefixIcon: Icons.lock,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Sign In Button (Stitch 60px primary action)
              AppButton(
                text: 'Sign In',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
                isLoading: authViewModel.isBusy,
                trailingIcon: const Icon(
                  Icons.login_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                onPressed: _handleLogin,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sample Demo Login Quick Fill Helper
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppSpacing.roundedMd,
                  onTap: () {
                    HapticService.selection();
                    _usernameController.text = 'abhishek';
                    _passwordController.text = '123456';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainerHighest
                          : AppColors.lightSurfaceSubtle,
                      borderRadius: AppSpacing.roundedMd,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.key_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            'Demo: abhishek / 123456 (Tap to fill)',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BRAND LOGO CONTAINER
  // ---------------------------------------------------------------------------
  Widget _buildLogoContainer({required double size}) {
    return NeramLogoBadge(size: size);
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerHighest
            : Colors.white.withAlpha(200),
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
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
}

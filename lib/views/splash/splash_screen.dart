import 'package:flutter/material.dart';
import 'package:neram_pos/core/constants/asset_constants.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/utils/jumping_page_route.dart';
import 'package:neram_pos/core/widgets/neram_brand_title.dart';
import 'package:neram_pos/core/widgets/neram_logo_badge.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:neram_pos/views/home/home_view.dart';
import 'package:provider/provider.dart';

/// Fantastic animated splash screen showcasing brand identity with the beloved
/// spring bounce entrance, zoom in & out pulse animation, and jumping transition.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Allows automated widget tests to shorten wait times.
  static bool enableAnimations = true;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoRotationAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;

  bool _hasPrecached = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Initial energetic elastic spring entrance (0% -> 55%)
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    // Subtle rotational flourish on entry
    _logoRotationAnimation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // Beloved zoom in and zoom out breathing pulse sequence (55% -> 100%)
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 1.0),
      ),
    );

    // Staggered brand title reveal
    _titleFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.45, 0.90, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();

    // Tactile sensation timed with the initial elastic landing
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (mounted) {
        HapticService.mediumImpact();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppAndNavigate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPrecached) {
      _hasPrecached = true;
      precacheImage(const AssetImage(AssetConstants.appLogo), context);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeAppAndNavigate() async {
    final startTime = DateTime.now();

    // Verify token & authentication status
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.checkAuthStatus();

    // Ensure full animation (elastic entrance + zoom in/out pulse) is clearly appreciated
    final elapsed = DateTime.now().difference(startTime);
    final minSplashDuration = SplashScreen.enableAnimations
        ? const Duration(milliseconds: 2400)
        : const Duration(milliseconds: 1500);

    final remaining = minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    // Jumping transition haptic
    HapticService.lightImpact();

    // When staff is already authenticated, jump straight to Home dashboard
    final destination = authViewModel.isAuthenticated
        ? const HomeView()
        : const LoginView();

    Navigator.of(
      context,
    ).pushReplacement(JumpingPageRoute<void>(page: destination));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient warm background glow that expands with zoom in & out
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final scale = _logoScaleAnimation.value * _pulseAnimation.value;
              return Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.05),
                      radius: 0.9 + (0.3 * (scale > 0 ? (scale - 1.0) : 0)),
                      colors: isDark
                          ? const [Color(0x28F59E0B), Colors.transparent]
                          : const [Color(0x20F59E0B), Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),

          // Main Centered Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elastic bounce & zoom in and out pulse logo badge
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final scale =
                        _logoScaleAnimation.value * _pulseAnimation.value;
                    return Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: const NeramLogoBadge(size: 100),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Staggered Title Slide & Fade
                FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: SlideTransition(
                    position: _titleSlideAnimation,
                    child: const NeramBrandTitle(
                      titleFontSize: 32,
                      subtitleFontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

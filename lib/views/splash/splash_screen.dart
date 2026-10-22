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

/// Fantastic animated splash screen showcasing brand identity with an elegant
/// entrance, continuous breathing ambient glow, and dynamic POS loading indicator.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Allows automated widget tests to disable looping animations.
  static bool enableAnimations = true;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoOpacityAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _loaderFadeAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  bool _hasPrecached = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Smooth entrance: opacity fade and gentle scale-in (0.80 -> 1.0)
    // Starting at 0.80 prevents the logo from disappearing to 0 after Android system splash
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
      ),
    );

    // Staggered brand title reveal
    _titleFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.80, curve: Curves.easeIn),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // Status indicator fade-in
    _loaderFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
    );

    // Continuous breathing pulse (never looks frozen or stuck)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _entranceController.forward();

    if (SplashScreen.enableAnimations) {
      _pulseController.repeat(reverse: true);
    }

    // Tactile sensation timed with the initial elastic landing
    Future<void>.delayed(const Duration(milliseconds: 320), () {
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
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeAppAndNavigate() async {
    final startTime = DateTime.now();

    // Verify token & authentication status
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.checkAuthStatus();

    // Ensure animation is clearly appreciated before transition
    final elapsed = DateTime.now().difference(startTime);
    final minSplashDuration = SplashScreen.enableAnimations
        ? const Duration(milliseconds: 2200)
        : const Duration(milliseconds: 1500);

    final remaining = minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    // Stop repeating controller before transition
    _pulseController.stop();

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
          // Dynamic ambient warm background glow (breathing smoothly)
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              final glowMultiplier = _glowAnimation.value;
              return Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.1),
                      radius: 0.95 * glowMultiplier,
                      colors: isDark
                          ? [
                              Color.lerp(
                                const Color(0x30E26E1B),
                                const Color(0x45E26E1B),
                                (_pulseController.value),
                              )!,
                              Colors.transparent,
                            ]
                          : [
                              Color.lerp(
                                const Color(0x20F59E0B),
                                const Color(0x35F59E0B),
                                (_pulseController.value),
                              )!,
                              Colors.transparent,
                            ],
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
                // Smooth fade & gentle scale logo badge with continuous breathing
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoScaleAnimation,
                    _logoOpacityAnimation,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    final scale =
                        _logoScaleAnimation.value * _pulseAnimation.value;
                    final opacity = _logoOpacityAnimation.value.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: const NeramLogoBadge(size: 104),
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

          // Bottom Active Status Indicator (proves system is alive and loading)
          Positioned(
            bottom: 48,
            child: FadeTransition(
              opacity: _loaderFadeAnimation,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final t = _pulseController.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3 pulsing amber micro-dots
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final offset = (t + (index * 0.25)) % 1.0;
                          final dotOpacity = 0.35 + (0.65 * offset);
                          final dotScale = 0.85 + (0.35 * offset);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                            width: 6 * dotScale,
                            height: 6 * dotScale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(
                                alpha: dotOpacity,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'INITIALIZING POS TERMINAL',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                              : AppColors.lightTextSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

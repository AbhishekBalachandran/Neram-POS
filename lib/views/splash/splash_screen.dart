import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/utils/jumping_page_route.dart';
import 'package:neram_pos/core/widgets/neram_brand_title.dart';
import 'package:neram_pos/core/widgets/neram_logo_badge.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/views/auth/login_view.dart';
import 'package:provider/provider.dart';

/// Fantastic animated splash screen showcasing brand identity with a spring
/// bounce logo entrance, breathing glow, and a jumping transition to Login/Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Initial energetic elastic spring entrance (0% -> 60%)
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.60, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );

    // Staggered breathing pulse sequence following the bounce (60% -> 100%)
    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.0,
              end: 1.08,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.08,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.60, 1.0),
          ),
        );

    // Staggered brand title reveal
    _titleFadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.50, 0.90, curve: Curves.easeIn),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.40), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.50, 0.95, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();

    // Tactile sensation timed with the initial elastic landing
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (mounted) {
        HapticService.mediumImpact();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppAndNavigate();
    });
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

    // Ensure animation is appreciated before transition
    final elapsed = DateTime.now().difference(startTime);
    const minSplashDuration = Duration(milliseconds: 1800);
    final remaining = minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    // Jumping transition haptic
    HapticService.lightImpact();

    // When dedicated Home dashboard is built, destination can branch here:
    // final destination = authViewModel.isAuthenticated ? const HomeView() : const LoginView();
    const Widget destination = LoginView();

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
          // Ambient warm background glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: isDark
                      ? const [Color(0x1EF59E0B), Colors.transparent]
                      : const [Color(0x18F59E0B), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main Centered Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elastic bounce & breathing pulse logo badge
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
                  child: const NeramLogoBadge(size: 96),
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

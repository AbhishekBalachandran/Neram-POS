import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';

/// Reusable bottom sheet utility providing energetic jumping / spring overshoot animations
/// and tactile haptic feedback whenever bottom sheets appear or dismiss.
class AppBottomSheet {
  const AppBottomSheet._();

  /// Signature jumping animation style: overshoots slightly upon entrance and snaps into place.
  static const AnimationStyle jumpingStyle = AnimationStyle(
    duration: Duration(milliseconds: 480),
    reverseDuration: Duration(milliseconds: 240),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );

  /// Shows a modal bottom sheet with a bouncy jumping entrance animation.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    Color backgroundColor = Colors.transparent,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = false,
  }) {
    HapticService.selection();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      sheetAnimationStyle: jumpingStyle,
      builder: (sheetContext) =>
          JumpingBottomSheetWrapper(child: builder(sheetContext)),
    );
  }
}

/// Content wrapper that applies an elastic, tactile jump and subtle spring settle
/// when mounted inside a modal bottom sheet.
class JumpingBottomSheetWrapper extends StatefulWidget {
  const JumpingBottomSheetWrapper({required this.child, super.key});

  final Widget child;

  @override
  State<JumpingBottomSheetWrapper> createState() =>
      _JumpingBottomSheetWrapperState();
}

class _JumpingBottomSheetWrapperState extends State<JumpingBottomSheetWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Spring overshoot curve for tactile jumping effect
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

import 'package:flutter/material.dart';

/// Custom animated page route featuring a lively jump-and-bounce entrance.
class JumpingPageRoute<T> extends PageRouteBuilder<T> {
  JumpingPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 700),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: const Duration(milliseconds: 400),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Spring jump curve with a slight overshoot bounce
           final jumpCurve = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutBack,
             reverseCurve: Curves.easeInBack,
           );

           final fadeAnimation = CurvedAnimation(
             parent: animation,
             curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
           );

           final slideAnimation = Tween<Offset>(
             begin: const Offset(0.0, 0.18),
             end: Offset.zero,
           ).animate(jumpCurve);

           final scaleAnimation = Tween<double>(
             begin: 0.82,
             end: 1.0,
           ).animate(jumpCurve);

           return FadeTransition(
             opacity: fadeAnimation,
             child: SlideTransition(
               position: slideAnimation,
               child: ScaleTransition(scale: scaleAnimation, child: child),
             ),
           );
         },
       );
}

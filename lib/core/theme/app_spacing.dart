import 'package:flutter/material.dart';

/// Standard spacing, padding, radius, and elevation tokens.
abstract final class AppSpacing {
  // Spacing Units
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Insets
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets p4 = EdgeInsets.all(xs);
  static const EdgeInsets p8 = EdgeInsets.all(sm);
  static const EdgeInsets p12 = EdgeInsets.all(md);
  static const EdgeInsets p16 = EdgeInsets.all(lg);
  static const EdgeInsets p20 = EdgeInsets.all(xl);
  static const EdgeInsets p24 = EdgeInsets.all(xxl);

  static const EdgeInsets px8 = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets px12 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets px16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets px20 = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets px24 = EdgeInsets.symmetric(horizontal: xxl);

  static const EdgeInsets py4 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets py8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets py12 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets py16 = EdgeInsets.symmetric(vertical: lg);

  // Border Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(
    Radius.circular(radiusSm),
  );
  static const BorderRadius roundedMd = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  static const BorderRadius roundedLg = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius roundedXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );
}

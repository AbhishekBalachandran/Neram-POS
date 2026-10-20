import 'package:flutter/services.dart';

/// Haptic feedback utility providing tactile sensations for POS staff interactions.
class HapticService {
  HapticService._();

  static bool isEnabled = true;

  /// Subtle click for minor selection, tab switch, or navigation item tap.
  static Future<void> selection() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Light impact for item counter increment/decrement or toggle switch.
  static Future<void> lightImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for primary actions like adding an order item or placing ticket.
  static Future<void> mediumImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for critical operations (bill settlement, KDS punch, punch out).
  static Future<void> heavyImpact() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Success sensation: quick double pulse sequence.
  static Future<void> success() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.lightImpact();
  }

  /// Warning / Error vibration pattern.
  static Future<void> error() async {
    if (!isEnabled) return;
    await HapticFeedback.vibrate();
  }
}

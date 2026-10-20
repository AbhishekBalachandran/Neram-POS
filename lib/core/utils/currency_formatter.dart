import 'package:intl/intl.dart';

/// Formatter for restaurant POS prices, taxes, discounts, and currency totals.
abstract final class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats [amount] with currency symbol and 2 decimal places (e.g. ₹250.00).
  static String format(num amount) {
    return _currencyFormat.format(amount);
  }

  /// Formats round integers without decimals (e.g. ₹250).
  static String formatCompact(num amount) {
    if (amount % 1 == 0) {
      return _compactCurrencyFormat.format(amount);
    }
    return _currencyFormat.format(amount);
  }
}

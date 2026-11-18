class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numerical [amount] into a standard currency string representation ($X.XX).
  static String format(num amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Formats a numerical [amount] as a clean number without currency symbols (e.g. 15.000 or 3.50).
  static String formatNumber(num amount) {
    if (amount == 0) return '0';
    if (amount % 1 == 0) {
      final str = amount.toInt().toString();
      return str.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
    } else {
      final fixed = amount.toStringAsFixed(2);
      final parts = fixed.split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      return '$intPart.${parts[1]}';
    }
  }
}

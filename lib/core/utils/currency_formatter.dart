class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numerical [amount] into a standard currency string representation ($X.XX).
  static String format(num amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

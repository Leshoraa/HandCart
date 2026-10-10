class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(num amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String formatRupiah(num amount) => format(amount);
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatRupiah(num amount) {
    final int value = amount.round();
    final String str = value.toString();
    final StringBuffer result = StringBuffer();

    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        result.write('.');
      }
    }

    return 'Rp ${result.toString().split('').reversed.join('')}';
  }
}

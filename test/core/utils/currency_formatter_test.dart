import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats integers with two decimal points and dollar prefix', () {
      expect(CurrencyFormatter.format(10), equals('\$10.00'));
      expect(CurrencyFormatter.format(0), equals('\$0.00'));
    });

    test('formats decimal values rounded to two decimal places', () {
      expect(CurrencyFormatter.format(4.5), equals('\$4.50'));
      expect(CurrencyFormatter.format(12.99), equals('\$12.99'));
      expect(CurrencyFormatter.format(15.999), equals('\$16.00'));
    });
  });
}

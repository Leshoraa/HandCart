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

    test('formatNumber formats numbers without currency symbols', () {
      expect(CurrencyFormatter.formatNumber(0), equals('0'));
      expect(CurrencyFormatter.formatNumber(10), equals('10'));
      expect(CurrencyFormatter.formatNumber(1000), equals('1.000'));
      expect(CurrencyFormatter.formatNumber(15000), equals('15.000'));
      expect(CurrencyFormatter.formatNumber(1500000), equals('1.500.000'));
      expect(CurrencyFormatter.formatNumber(3.5), equals('3.50'));
      expect(CurrencyFormatter.formatNumber(12.99), equals('12.99'));
    });
  });
}

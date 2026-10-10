import 'package:flutter_test/flutter_test.dart';
import 'package:handcart/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatRelativeDate returns Today for the current date', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelativeDate(now), equals('Today'));
    });

    test('formatRelativeDate returns Yesterday for the previous day', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.formatRelativeDate(yesterday), equals('Yesterday'));
    });

    test('formatRelativeDate returns day, month, date, year for older dates', () {
      final sampleDate = DateTime(2026, 1, 19); // Jan 19, 2026 was a Monday
      final formatted = DateFormatter.formatRelativeDate(sampleDate);
      expect(formatted, equals('Monday, Jan 19, 2026'));
    });
  });
}

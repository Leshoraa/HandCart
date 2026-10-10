class DateFormatter {
  DateFormatter._();

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Mengubah [DateTime] menjadi teks tanggal relatif dalam Bahasa Indonesia:
  /// - Hari ini -> "Hari Ini"
  /// - Kemarin -> "Kemarin"
  /// - Tanggal lainnya -> misal "Selasa, 19 Jan 2026"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'Hari Ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else {
      final dayName = _days[date.weekday - 1];
      final monthName = _months[date.month - 1];
      return '$dayName, ${date.day} $monthName ${date.year}';
    }
  }
}

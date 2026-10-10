class DateFormatter {
  DateFormatter._();

  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formats a [DateTime] into relative English date text:
  /// - Today -> "Today"
  /// - Yesterday -> "Yesterday"
  /// - Older dates -> e.g. "Tuesday, Jan 19, 2026"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      final dayName = _days[date.weekday - 1];
      final monthName = _months[date.month - 1];
      return '$dayName, $monthName ${date.day}, ${date.year}';
    }
  }
}

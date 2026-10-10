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

  /// Formats a [DateTime] into a relative or formatted date string:
  /// - Returns 'Today' if [date] matches current calendar day.
  /// - Returns 'Yesterday' if [date] was the previous calendar day.
  /// - Returns formatted '[DayName], [MonthName] [Day], [Year]' for other dates.
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Yesterday';
    }

    final dayName = _days[date.weekday - 1];
    final monthName = _months[date.month - 1];
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }
}

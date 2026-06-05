import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String getTodayDateString() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  static String formatDate(String dateString, {String format = 'MMM d, yyyy'}) {
    final date = DateTime.parse(dateString);
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime dateTime, {String format = 'MMM d, yyyy h:mm a'}) {
    return DateFormat(format).format(dateTime);
  }

  static int daysBetween(String dateStr1, String dateStr2) {
    final d1 = DateTime.parse(dateStr1);
    final d2 = DateTime.parse(dateStr2);
    return d2.difference(d1).inDays;
  }

  static String getRelativeDay(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEEE, MMM d').format(date);
  }

  static String getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

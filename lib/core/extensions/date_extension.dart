import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  /// Example: 15 Jun 2027
  String get formatted => DateFormat('d MMM yyyy').format(this);

  /// Days left from today (negative if the date has passed).
  int get daysFromNow {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(year, month, day);
    return end.difference(start).inDays;
  }

  bool get isPast => daysFromNow < 0;
}
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get formatted => DateFormat('d MMM yyyy').format(this);

  String get formattedDateTime => DateFormat('d MMM yyyy, h:mm a').format(this);

  int daysSince(DateTime from) {
    final end = DateTime.utc(year, month, day);
    final start = DateTime.utc(from.year, from.month, from.day);
    return end.difference(start).inDays;
  }

  int get daysFromNow => daysSince(DateTime.now());

  bool get isPast => daysFromNow < 0;
}

import '../constants/app_strings.dart';

abstract final class Validators {
  static const int maxName = 60;
  static const int maxAddress = 120;

  static const int maxIssueTitle = 80;
  static const int maxNote = 500;

  static String? text(
      String? value, {
        required String emptyMessage,
        required int maxLength,
      }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return emptyMessage;
    if (text.length > maxLength) {
      return 'Keep it under $maxLength characters';
    }
    return null;
  }

  static String? date(DateTime? value) =>
      value == null ? AppStrings.selectDate : null;

  static String? leaseEnd(DateTime? end, DateTime? start) {
    if (end == null) return AppStrings.selectDate;
    if (start != null && !end.isAfter(start)) {
      return AppStrings.leaseEndAfterStart;
    }
    return null;
  }
}
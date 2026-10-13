import 'package:uuid/uuid.dart';

abstract final class AppUtils {
  static const Uuid _uuid = Uuid();

  static String generateId() => _uuid.v4();
}
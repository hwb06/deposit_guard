import 'package:flutter/foundation.dart';

/// Build-time switches.
abstract final class AppFlags {
  static const bool _qaToolsDefine = bool.fromEnvironment('QA_TOOLS');

  static bool get showQaTools => kDebugMode || _qaToolsDefine;
}

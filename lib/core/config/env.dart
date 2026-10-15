import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads secrets from the bundled `.env` file.
/// Nothing is hardcoded; missing values simply disable that feature.
abstract final class Env {
  static bool _loaded = false;

  static Future<void> load() async {
    try {
      await dotenv.load();
      _loaded = true;
    } catch (error) {
      debugPrint('Env: could not load .env ($error)');
    }
  }

  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');
  static String get sentryDsn => _read('SENTRY_DSN');

  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('https://') &&
          supabaseAnonKey.isNotEmpty &&
          !supabaseUrl.contains('your_');

  static String _read(String key) =>
      _loaded ? (dotenv.maybeGet(key)?.trim() ?? '') : '';
}
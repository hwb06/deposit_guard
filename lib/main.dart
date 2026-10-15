import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'bloc/app_bloc_observer.dart';
import 'core/config/env.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  final dsn = Env.sentryDsn;
  if (dsn.isEmpty || dsn.contains('your_')) {
    debugPrint('Sentry is not configured. Error tracking is off.');
    await _bootstrap();
    return;
  }

  await SentryFlutter.init(
        (options) {
      options.dsn = dsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.sendDefaultPii = false; // no IP / user data
      options.tracesSampleRate = 0; // errors only, no performance traces
    },
    appRunner: _bootstrap,
  );
}

Future<void> _bootstrap() async {
  Bloc.observer = const AppBlocObserver();

  final authAvailable = await _initSupabase();
  await initDependencies(authAvailable: authAvailable);

  runApp(const DepositGuardApp());
}

/// Returns false (guest-only mode) when keys are missing or init fails.
Future<bool> _initSupabase() async {
  if (!Env.isSupabaseConfigured) {
    debugPrint('Supabase is not configured. Running in guest-only mode.');
    return false;
  }
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    return true;
  } catch (error) {
    debugPrint('Supabase init failed: $error');
    return false;
  }
}

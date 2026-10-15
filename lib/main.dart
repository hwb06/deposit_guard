import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'bloc/app_bloc_observer.dart';
import 'core/config/env.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  await Env.load();
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
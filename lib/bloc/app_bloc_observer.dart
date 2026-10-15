import 'package:deposit_guard/bloc/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    // Never print auth events: they contain passwords.
    if (kDebugMode && bloc is! AuthBloc) {
      debugPrint('[${bloc.runtimeType}] event: $event');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[${bloc.runtimeType}] error: $error');
    }
    // No-op when Sentry was not initialised (no DSN).
    Sentry.captureException(error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

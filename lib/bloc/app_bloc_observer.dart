import 'package:deposit_guard/bloc/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    // TODO(phase-6): report to Sentry via ErrorTrackingService.
    super.onError(bloc, error, stackTrace);
  }
}
import 'dart:async';
import 'package:deposit_guard/services/connectivity_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_state.dart';

/// Keeps the app informed about network status (used by the offline banner).
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._service) : super(const ConnectivityState()) {
    _subscription = _service.onlineChanges.listen(_update);
    _service.isOnline.then(_update);
  }

  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  void _update(bool isOnline) {
    if (!isClosed) emit(ConnectivityState(isOnline: isOnline));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

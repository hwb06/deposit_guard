import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthRepository repository)
      : _repository = repository,
        super(AuthState(user: repository.currentUser)) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInSubmitted>(_onSignIn);
    on<AuthSignUpSubmitted>(_onSignUp);
    on<AuthSignOutPressed>(_onSignOut);
  }

  final AuthRepository _repository;

  /// False when Supabase is not configured (guest-only build).
  bool get isAvailable => _repository.isAvailable;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    return emit.forEach<AppUser?>(
      _repository.userChanges,
      onData: (user) => AuthState(user: user),
    );
  }

  Future<void> _onSignIn(AuthSignInSubmitted event, Emitter<AuthState> emit) {
    return _run(emit, () async {
      await _repository.signIn(email: event.email, password: event.password);
      return null;
    });
  }

  Future<void> _onSignUp(AuthSignUpSubmitted event, Emitter<AuthState> emit) {
    return _run(emit, () async {
      final needsConfirmation = await _repository.signUp(
        email: event.email,
        password: event.password,
      );
      return needsConfirmation ? AppStrings.authCheckEmail : null;
    });
  }

  Future<void> _onSignOut(AuthSignOutPressed event, Emitter<AuthState> emit) {
    return _run(emit, () async {
      await _repository.signOut();
      return null;
    });
  }

  /// Runs [action] with a busy state. The action may return a notice
  /// message to show the user (for example "check your email").
  Future<void> _run(
      Emitter<AuthState> emit,
      Future<String?> Function() action,
      ) async {
    emit(AuthState(user: state.user, busy: true));
    try {
      final notice = await action();
      emit(AuthState(user: _repository.currentUser, noticeMessage: notice));
    } on AuthFailure catch (failure) {
      emit(AuthState(user: state.user, errorMessage: failure.message));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        AuthState(user: state.user, errorMessage: AppStrings.authGeneric),
      );
    }
  }
}
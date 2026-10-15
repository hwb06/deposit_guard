import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/constants/app_strings.dart';
import '../models/app_user.dart';

/// An error that is safe to show directly to the user.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

/// Wraps Supabase Auth. When [_auth] is null (Supabase not configured),
/// the app runs in guest-only mode.
class AuthRepository {
  const AuthRepository(this._auth);

  final supabase.GoTrueClient? _auth;

  bool get isAvailable => _auth != null;

  AppUser? get currentUser => _toUser(_auth?.currentUser);

  Stream<AppUser?> get userChanges {
    final auth = _auth;
    if (auth == null) return const Stream.empty();
    return auth.onAuthStateChange.map((state) => _toUser(state.session?.user));
  }

  Future<void> signIn({required String email, required String password}) =>
      _guard((auth) => auth.signInWithPassword(email: email, password: password));

  /// Returns true when the user must confirm their email before signing in.
  Future<bool> signUp({required String email, required String password}) async {
    final response = await _guard(
          (auth) => auth.signUp(email: email, password: password),
    );
    return response.session == null;
  }

  Future<void> signOut() => _guard((auth) => auth.signOut());

  Future<T> _guard<T>(
      Future<T> Function(supabase.GoTrueClient auth) action,
      ) async {
    final auth = _auth;
    if (auth == null) throw const AuthFailure(AppStrings.authUnavailable);

    try {
      return await action(auth);
    } on supabase.AuthException catch (error) {
      throw _failureFrom(error.message);
    } catch (_) {
      // Non-auth errors here are almost always connection problems.
      throw const AuthFailure(AppStrings.authNetworkError);
    }
  }

  AuthFailure _failureFrom(String raw) {
    final message = raw.toLowerCase();

    if (message.contains('invalid login')) {
      return const AuthFailure(AppStrings.authInvalidCredentials);
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return const AuthFailure(AppStrings.authEmailTaken);
    }
    if (message.contains('not confirmed')) {
      return const AuthFailure(AppStrings.authEmailNotConfirmed);
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return const AuthFailure(AppStrings.authRateLimited);
    }
    if (message.contains('socket') ||
        message.contains('host lookup') ||
        message.contains('clientexception') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('timed out')) {
      return const AuthFailure(AppStrings.authNetworkError);
    }
    return const AuthFailure(AppStrings.authGeneric);
  }

  AppUser? _toUser(supabase.User? user) =>
      user == null ? null : AppUser(id: user.id, email: user.email);
}
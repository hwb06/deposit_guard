import 'package:equatable/equatable.dart';

import '../../data/models/app_user.dart';

final class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.busy = false,
    this.errorMessage,
    this.noticeMessage,
  });

  /// Null means guest mode.
  final AppUser? user;
  final bool busy;
  final String? errorMessage;
  final String? noticeMessage;

  bool get isSignedIn => user != null;

  @override
  List<Object?> get props => [user, busy, errorMessage, noticeMessage];
}
import 'package:equatable/equatable.dart';

enum BackupStatus { idle, backingUp, restoring, backedUp, restored, failure }

final class BackupState extends Equatable {
  const BackupState({
    this.status = BackupStatus.idle,
    this.lastBackup,
    this.progress,
    this.message,
  });

  final BackupStatus status;
  final DateTime? lastBackup;

  final String? progress;

  final String? message;

  bool get busy =>
      status == BackupStatus.backingUp || status == BackupStatus.restoring;

  BackupState copyWith({
    BackupStatus? status,
    DateTime? lastBackup,
    String? progress,
    String? message,
  }) =>
      BackupState(
        status: status ?? this.status,
        lastBackup: lastBackup ?? this.lastBackup,
        progress: progress,
        message: message,
      );

  @override
  List<Object?> get props => [status, lastBackup, progress, message];
}
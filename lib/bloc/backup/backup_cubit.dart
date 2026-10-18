import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/backup_failure.dart';
import '../../data/repositories/backup_repository.dart';
import '../../services/connectivity_service.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  BackupCubit(BackupRepository repository, ConnectivityService connectivity)
      : _repository = repository,
        _connectivity = connectivity,
        super(BackupState(lastBackup: repository.lastBackup));

  final BackupRepository _repository;
  final ConnectivityService _connectivity;

  void refresh() {
    if (state.busy) return;
    _emit(BackupState(lastBackup: _repository.lastBackup));
  }

  Future<void> backUp() async {
    if (state.busy) return;
    if (!await _connectivity.isOnline) {
      _fail(AppStrings.offlineAction);
      return;
    }
    _emit(
      state.copyWith(
        status: BackupStatus.backingUp,
        progress: AppStrings.backupChecking,
      ),
    );

    try {
      final summary = await _repository.backUp(onProgress: _onProgress);
      _emit(
        BackupState(
          status: BackupStatus.backedUp,
          lastBackup: _repository.lastBackup,
          message: summary.isEmpty
              ? AppStrings.backupUpToDate
              : AppStrings.backupDone(
            rentals: summary.rentals,
            issues: summary.issues,
            photos: summary.photos,
            removed: summary.removed,
          ),
        ),
      );
    } on BackupFailure catch (failure) {
      _fail(failure.message);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      _fail(AppStrings.backupGeneric);
    }
  }

  Future<void> restore() async {
    if (state.busy) return;
    if (!await _connectivity.isOnline) {
      _fail(AppStrings.offlineAction);
      return;
    }
    _emit(
      state.copyWith(
        status: BackupStatus.restoring,
        progress: AppStrings.restoreReading,
      ),
    );

    try {
      final summary = await _repository.restore(onProgress: _onProgress);
      _emit(
        BackupState(
          status: BackupStatus.restored,
          lastBackup: _repository.lastBackup,
          message: summary.isEmpty
              ? AppStrings.restoreNothingNew
              : AppStrings.restoreDone(
            rentals: summary.rentals,
            issues: summary.issues,
            photos: summary.photos,
            photoFailures: summary.photoFailures,
          ),
        ),
      );
    } on BackupFailure catch (failure) {
      _fail(failure.message);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      _fail(AppStrings.restoreGeneric);
    }
  }

  void _onProgress(String message) {
    if (state.busy) _emit(state.copyWith(progress: message));
  }

  void _fail(String message) => _emit(
    BackupState(
      status: BackupStatus.failure,
      lastBackup: _repository.lastBackup,
      message: message,
    ),
  );

  void _emit(BackupState next) {
    if (!isClosed) emit(next);
  }
}
import 'dart:async';

import 'package:deposit_guard/services/image/image_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/issue_model.dart';
import '../../data/models/issue_severity.dart';
import '../../data/models/issue_stage.dart';
import '../../data/repositories/issue_repository.dart';
import 'issue_form_state.dart';

class IssueFormCubit extends Cubit<IssueFormState> {
  IssueFormCubit(this._issues, this._images) : super(const IssueFormState());

  final IssueRepository _issues;
  final ImageService _images;

  String? _originalPhoto;
  final List<String> _pendingPhotos = [];
  bool _committed = false;

  void init(IssueModel? issue) {
    _originalPhoto = issue?.photoPath;
    emit(IssueFormState(photoName: issue?.photoPath));
  }

  Future<void> pickPhoto(ImageSource source) async {
    try {
      final name = await _images.pick(source);
      if (name == null || isClosed) return;
      _pendingPhotos.add(name);
      emit(state.copyWith(photoName: name));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      _fail(AppStrings.photoFailed);
    }
  }

  void removePhoto() => emit(state.copyWith(clearPhoto: true));

  Future<void> save({
    required String rentalId,
    required IssueModel? existing,
    required String title,
    required String room,
    required IssueSeverity severity,
    required IssueStage stage,
    required String note,
  }) async {
    emit(state.copyWith(status: IssueFormStatus.saving));

    final cleanNote = note.trim().isEmpty ? null : note.trim();
    final photo = state.photoName;

    try {
      if (existing == null) {
        await _issues.addIssue(
          IssueModel.create(
            rentalId: rentalId,
            title: title.trim(),
            room: room,
            severity: severity,
            stage: stage,
            note: cleanNote,
            photoPath: photo,
          ),
        );
      } else {
        // Built directly (not via copyWith) so note/photo can become null.
        await _issues.updateIssue(
          IssueModel(
            id: existing.id,
            rentalId: existing.rentalId,
            title: title.trim(),
            room: room,
            severity: severity,
            stage: stage,
            note: cleanNote,
            photoPath: photo,
            createdAt: existing.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      _fail(AppStrings.somethingWentWrong);
      return;
    }

    _committed = true;
    await _discardPhotos(keep: photo);
    if (isClosed) return;
    emit(state.copyWith(status: IssueFormStatus.done));
  }

  Future<void> delete(IssueModel issue) async {
    emit(state.copyWith(status: IssueFormStatus.saving));
    try {
      await _issues.deleteIssue(issue.id);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      _fail(AppStrings.somethingWentWrong);
      return;
    }

    _committed = true;
    await _discardPhotos(keep: null);
    if (isClosed) return;
    emit(state.copyWith(status: IssueFormStatus.done));
  }

  /// Emits the error once, then returns to the editing state so the
  /// same error can be shown again later.
  void _fail(String message) {
    if (isClosed) return;
    emit(state.copyWith(status: IssueFormStatus.failure, errorMessage: message));
    emit(state.copyWith(status: IssueFormStatus.editing));
  }

  /// Deletes every photo file except [keep] (original and newly picked).
  Future<void> _discardPhotos({required String? keep}) async {
    final stale = <String>{
      ..._pendingPhotos,
      if (_originalPhoto != null) _originalPhoto!,
    }..remove(keep);
    for (final name in stale) {
      await _images.delete(name);
    }
  }

  @override
  Future<void> close() {
    // Form closed without saving: remove photos picked during this session.
    if (!_committed) {
      for (final name in _pendingPhotos) {
        unawaited(_images.delete(name));
      }
    }
    return super.close();
  }
}
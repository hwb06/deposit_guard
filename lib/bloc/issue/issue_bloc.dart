import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../data/repositories/issue_repository.dart';
import 'issue_event.dart';
import 'issue_filter.dart';
import 'issue_state.dart';

class IssueBloc extends Bloc<IssueEvent, IssueState> {
  IssueBloc(this._repository) : super(const IssueState()) {
    on<IssuesLoaded>(_onLoaded);
    on<IssuesRefreshed>((_, emit) => _fetch(emit));
    on<IssueRoomSelected>(
          (event, emit) => _applyFilter(emit, state.filter.withRoom(event.room)),
    );
    on<IssueSeveritySelected>(
          (event, emit) =>
          _applyFilter(emit, state.filter.withSeverity(event.severity)),
    );
    on<IssueSearched>(_onSearched, transformer: restartable());
  }

  static const Duration _searchDebounce = Duration(milliseconds: 300);

  final IssueRepository _repository;

  Future<void> _onLoaded(
      IssuesLoaded event,
      Emitter<IssueState> emit,
      ) async {
    emit(
      state.copyWith(status: IssueStatus.loading, rentalId: event.rentalId),
    );
    await _fetch(emit);
  }

  /// `restartable()` cancels the previous search, so this delay
  /// works as a debounce.
  Future<void> _onSearched(
      IssueSearched event,
      Emitter<IssueState> emit,
      ) async {
    await Future<void>.delayed(_searchDebounce);
    if (emit.isDone) return; // a newer search replaced this one
    await _applyFilter(emit, state.filter.withQuery(event.query));
  }

  Future<void> _applyFilter(
      Emitter<IssueState> emit,
      IssueFilter filter,
      ) async {
    emit(state.copyWith(filter: filter));
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<IssueState> emit) async {
    try {
      final filter = state.filter;
      final issues = await _repository.getIssues(
        state.rentalId,
        room: filter.room,
        severity: filter.severity,
        query: filter.query,
      );
      emit(state.copyWith(status: IssueStatus.success, issues: issues));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: IssueStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }
}
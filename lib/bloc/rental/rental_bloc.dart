import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../data/repositories/rental_repository.dart';
import 'rental_event.dart';
import 'rental_state.dart';

class RentalBloc extends Bloc<RentalEvent, RentalState> {
  RentalBloc(this._repository) : super(const RentalState()) {
    on<RentalsLoaded>(_onLoaded);
    on<RentalsSearched>(_onSearched, transformer: restartable());
    on<RentalAdded>(
          (event, emit) => _mutate(emit, () => _repository.addRental(event.rental)),
    );
    on<RentalUpdated>(
          (event, emit) =>
          _mutate(emit, () => _repository.updateRental(event.rental)),
    );
    on<RentalDeleted>(
          (event, emit) => _mutate(emit, () => _repository.deleteRental(event.id)),
    );
  }

  static const Duration _searchDebounce = Duration(milliseconds: 300);

  final RentalRepository _repository;

  Future<void> _onLoaded(
      RentalsLoaded event,
      Emitter<RentalState> emit,
      ) async {
    emit(state.copyWith(status: RentalStatus.loading));
    await _fetch(emit);
  }

  /// `restartable()` cancels the previous search, so waiting here
  /// acts as a debounce: only the last keystroke runs a query.
  Future<void> _onSearched(
      RentalsSearched event,
      Emitter<RentalState> emit,
      ) async {
    await Future<void>.delayed(_searchDebounce);
    emit(state.copyWith(query: event.query, rentals: state.rentals));
    await _fetch(emit);
  }

  /// Runs a write operation, then refreshes the list.
  Future<void> _mutate(
      Emitter<RentalState> emit,
      Future<void> Function() action,
      ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      _fail(emit, error, stackTrace);
      return;
    }
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<RentalState> emit) async {
    try {
      final rentals = await _repository.getRentals(query: state.query);
      emit(state.copyWith(status: RentalStatus.success, rentals: rentals));
    } catch (error, stackTrace) {
      _fail(emit, error, stackTrace);
    }
  }

  void _fail(Emitter<RentalState> emit, Object error, StackTrace stackTrace) {
    addError(error, stackTrace);
    emit(
      state.copyWith(
        status: RentalStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ),
    );
  }
}
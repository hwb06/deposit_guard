import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/issue_repository.dart';
import '../../data/repositories/rental_repository.dart';
import 'rental_detail_state.dart';

class RentalDetailCubit extends Cubit<RentalDetailState> {
  RentalDetailCubit(this._rentals, this._issues)
      : super(const RentalDetailState());

  final RentalRepository _rentals;
  final IssueRepository _issues;

  Future<void> load(String id) async {
    try {
      final rental = await _rentals.getRental(id);
      if (isClosed) return;

      if (rental == null) {
        emit(const RentalDetailState(status: RentalDetailStatus.notFound));
        return;
      }

      final issueCount = await _issues.countByRental(id);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: RentalDetailStatus.success,
          rental: rental,
          issueCount: issueCount,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      if (isClosed) return;
      emit(state.copyWith(status: RentalDetailStatus.failure));
    }
  }
}
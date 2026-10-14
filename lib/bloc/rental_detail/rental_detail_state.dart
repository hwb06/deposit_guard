import 'package:equatable/equatable.dart';

import '../../data/models/rental_model.dart';

enum RentalDetailStatus { loading, success, notFound, failure }

final class RentalDetailState extends Equatable {
  const RentalDetailState({
    this.status = RentalDetailStatus.loading,
    this.rental,
    this.issueCount = 0,
  });

  final RentalDetailStatus status;
  final RentalModel? rental;
  final int issueCount;

  RentalDetailState copyWith({
    RentalDetailStatus? status,
    RentalModel? rental,
    int? issueCount,
  }) =>
      RentalDetailState(
        status: status ?? this.status,
        rental: rental ?? this.rental,
        issueCount: issueCount ?? this.issueCount,
      );

  @override
  List<Object?> get props => [status, rental, issueCount];
}
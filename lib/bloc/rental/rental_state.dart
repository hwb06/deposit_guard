import 'package:equatable/equatable.dart';

import '../../data/models/rental_model.dart';

enum RentalStatus { loading, success, failure }

final class RentalState extends Equatable {
  const RentalState({
    this.status = RentalStatus.loading,
    this.rentals = const [],
    this.query = '',
    this.errorMessage,
  });

  final RentalStatus status;
  final List<RentalModel> rentals;
  final String query;
  final String? errorMessage;

  bool get isSearching => query.trim().isNotEmpty;

  RentalState copyWith({
    RentalStatus? status,
    List<RentalModel>? rentals,
    String? query,
    String? errorMessage,
  }) =>
      RentalState(
        status: status ?? this.status,
        rentals: rentals ?? this.rentals,
        query: query ?? this.query,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, rentals, query, errorMessage];
}
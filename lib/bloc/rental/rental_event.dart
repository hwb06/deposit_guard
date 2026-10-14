import 'package:equatable/equatable.dart';

import '../../data/models/rental_model.dart';

sealed class RentalEvent extends Equatable {
  const RentalEvent();

  @override
  List<Object?> get props => [];
}

final class RentalsLoaded extends RentalEvent {
  const RentalsLoaded();
}

final class RentalsSearched extends RentalEvent {
  const RentalsSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class RentalAdded extends RentalEvent {
  const RentalAdded(this.rental);

  final RentalModel rental;

  @override
  List<Object?> get props => [rental];
}

final class RentalUpdated extends RentalEvent {
  const RentalUpdated(this.rental);

  final RentalModel rental;

  @override
  List<Object?> get props => [rental];
}

final class RentalDeleted extends RentalEvent {
  const RentalDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
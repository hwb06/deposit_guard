
import '../local/rental_dao.dart';
import '../models/rental_model.dart';

class RentalRepository {
  const RentalRepository(this._dao);

  final RentalDao _dao;

  Future<List<RentalModel>> getRentals({String? query}) =>
      _dao.getAll(query: query);

  Future<RentalModel?> getRental(String id) => _dao.getById(id);

  Future<void> addRental(RentalModel rental) => _dao.insert(rental);

  Future<void> updateRental(RentalModel rental) =>
      _dao.update(rental.copyWith(updatedAt: DateTime.now()));

  Future<void> deleteRental(String id) => _dao.delete(id);

  /// Used by cloud restore. Keeps the original `updated_at` timestamps.
  Future<void> restoreRentals(List<RentalModel> rentals) =>
      _dao.upsertAll(rentals);

}
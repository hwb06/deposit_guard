abstract final class RentalTable {
  static const String table = 'rentals';
  static const String id = 'id';
  static const String name = 'name';
  static const String address = 'address';
  static const String leaseStart = 'lease_start';
  static const String leaseEnd = 'lease_end';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

abstract final class IssueTable {
  static const String table = 'issues';
  static const String id = 'id';
  static const String rentalId = 'rental_id';
  static const String title = 'title';
  static const String room = 'room';
  static const String severity = 'severity';
  static const String stage = 'stage';
  static const String note = 'note';
  static const String photoPath = 'photo_path';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
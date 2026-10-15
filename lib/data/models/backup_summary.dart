import 'package:equatable/equatable.dart';

/// What a backup or restore run actually changed.
class BackupSummary extends Equatable {
  const BackupSummary({
    this.rentals = 0,
    this.issues = 0,
    this.photos = 0,
    this.removed = 0,
    this.photoFailures = 0,
  });

  final int rentals;
  final int issues;
  final int photos;

  /// Items deleted from the cloud because they were deleted on this device.
  final int removed;

  /// Photos that could not be downloaded during a restore.
  final int photoFailures;

  bool get isEmpty =>
      rentals == 0 &&
          issues == 0 &&
          photos == 0 &&
          removed == 0 &&
          photoFailures == 0;

  @override
  List<Object?> get props => [rentals, issues, photos, removed, photoFailures];
}
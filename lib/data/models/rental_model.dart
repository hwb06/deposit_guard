import 'package:equatable/equatable.dart';

import '../../core/utils/app_utils.dart';
import '../local/db_tables.dart';

class RentalModel extends Equatable {
  const RentalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.leaseStart,
    required this.leaseEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalModel.create({
    required String name,
    required String address,
    required DateTime leaseStart,
    required DateTime leaseEnd,
  }) {
    final now = DateTime.now();
    return RentalModel(
      id: AppUtils.generateId(),
      name: name,
      address: address,
      leaseStart: leaseStart,
      leaseEnd: leaseEnd,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory RentalModel.fromMap(Map<String, Object?> map) => RentalModel(
    id: map[RentalTable.id] as String,
    name: map[RentalTable.name] as String,
    address: map[RentalTable.address] as String,
    leaseStart: DateTime.parse(map[RentalTable.leaseStart] as String),
    leaseEnd: DateTime.parse(map[RentalTable.leaseEnd] as String),
    createdAt: DateTime.parse(map[RentalTable.createdAt] as String),
    updatedAt: DateTime.parse(map[RentalTable.updatedAt] as String),
  );

  final String id;
  final String name;
  final String address;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalModel copyWith({
    String? name,
    String? address,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    DateTime? updatedAt,
  }) =>
      RentalModel(
        id: id,
        name: name ?? this.name,
        address: address ?? this.address,
        leaseStart: leaseStart ?? this.leaseStart,
        leaseEnd: leaseEnd ?? this.leaseEnd,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toMap() => {
    RentalTable.id: id,
    RentalTable.name: name,
    RentalTable.address: address,
    RentalTable.leaseStart: leaseStart.toIso8601String(),
    RentalTable.leaseEnd: leaseEnd.toIso8601String(),
    RentalTable.createdAt: createdAt.toIso8601String(),
    RentalTable.updatedAt: updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props =>
      [id, name, address, leaseStart, leaseEnd, createdAt, updatedAt];
}
import 'package:equatable/equatable.dart';

import '../../core/utils/app_utils.dart';
import '../local/db_tables.dart';
import 'issue_severity.dart';
import 'issue_stage.dart';

class IssueModel extends Equatable {
  const IssueModel({
    required this.id,
    required this.rentalId,
    required this.title,
    required this.room,
    required this.severity,
    required this.stage,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.photoPath,
  });

  factory IssueModel.create({
    required String rentalId,
    required String title,
    required String room,
    required IssueSeverity severity,
    required IssueStage stage,
    String? note,
    String? photoPath,
  }) {
    final now = DateTime.now();
    return IssueModel(
      id: AppUtils.generateId(),
      rentalId: rentalId,
      title: title,
      room: room,
      severity: severity,
      stage: stage,
      note: note,
      photoPath: photoPath,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory IssueModel.fromMap(Map<String, Object?> map) => IssueModel(
    id: map[IssueTable.id] as String,
    rentalId: map[IssueTable.rentalId] as String,
    title: map[IssueTable.title] as String,
    room: map[IssueTable.room] as String,
    severity: IssueSeverity.fromName(map[IssueTable.severity] as String),
    stage: IssueStage.fromName(map[IssueTable.stage] as String),
    note: map[IssueTable.note] as String?,
    photoPath: map[IssueTable.photoPath] as String?,
    createdAt: DateTime.parse(map[IssueTable.createdAt] as String),
    updatedAt: DateTime.parse(map[IssueTable.updatedAt] as String),
  );

  final String id;
  final String rentalId;
  final String title;
  final String room;
  final IssueSeverity severity;
  final IssueStage stage;
  final String? note;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  IssueModel copyWith({
    String? title,
    String? room,
    IssueSeverity? severity,
    IssueStage? stage,
    String? note,
    String? photoPath,
    DateTime? updatedAt,
  }) =>
      IssueModel(
        id: id,
        rentalId: rentalId,
        title: title ?? this.title,
        room: room ?? this.room,
        severity: severity ?? this.severity,
        stage: stage ?? this.stage,
        note: note ?? this.note,
        photoPath: photoPath ?? this.photoPath,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toMap() => {
    IssueTable.id: id,
    IssueTable.rentalId: rentalId,
    IssueTable.title: title,
    IssueTable.room: room,
    IssueTable.severity: severity.name,
    IssueTable.stage: stage.name,
    IssueTable.note: note,
    IssueTable.photoPath: photoPath,
    IssueTable.createdAt: createdAt.toIso8601String(),
    IssueTable.updatedAt: updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    rentalId,
    title,
    room,
    severity,
    stage,
    note,
    photoPath,
    createdAt,
    updatedAt,
  ];
}
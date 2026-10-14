import 'package:equatable/equatable.dart';

import '../../data/models/issue_severity.dart';

sealed class IssueEvent extends Equatable {
  const IssueEvent();

  @override
  List<Object?> get props => [];
}

final class IssuesLoaded extends IssueEvent {
  const IssuesLoaded(this.rentalId);

  final String rentalId;

  @override
  List<Object?> get props => [rentalId];
}

/// Reloads the list silently (no loading spinner).
final class IssuesRefreshed extends IssueEvent {
  const IssuesRefreshed();
}

final class IssueRoomSelected extends IssueEvent {
  const IssueRoomSelected(this.room);

  final String? room;

  @override
  List<Object?> get props => [room];
}

final class IssueSeveritySelected extends IssueEvent {
  const IssueSeveritySelected(this.severity);

  final IssueSeverity? severity;

  @override
  List<Object?> get props => [severity];
}

final class IssueSearched extends IssueEvent {
  const IssueSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
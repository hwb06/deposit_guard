import 'package:equatable/equatable.dart';
import '../../data/models/issue_severity.dart';

final class IssueFilter extends Equatable {
  const IssueFilter({this.room, this.severity, this.query = ''});

  final String? room;
  final IssueSeverity? severity;
  final String query;

  bool get isActive =>
      room != null || severity != null || query.trim().isNotEmpty;

  IssueFilter withRoom(String? room) =>
      IssueFilter(room: room, severity: severity, query: query);

  IssueFilter withSeverity(IssueSeverity? severity) =>
      IssueFilter(room: room, severity: severity, query: query);

  IssueFilter withQuery(String query) =>
      IssueFilter(room: room, severity: severity, query: query);

  @override
  List<Object?> get props => [room, severity, query];
}
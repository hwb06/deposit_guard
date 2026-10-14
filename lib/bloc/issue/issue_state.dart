import 'package:equatable/equatable.dart';

import '../../data/models/issue_model.dart';
import 'issue_filter.dart';

enum IssueStatus { loading, success, failure }

final class IssueState extends Equatable {
  const IssueState({
    this.status = IssueStatus.loading,
    this.rentalId = '',
    this.issues = const [],
    this.filter = const IssueFilter(),
    this.errorMessage,
  });

  final IssueStatus status;
  final String rentalId;
  final List<IssueModel> issues;
  final IssueFilter filter;
  final String? errorMessage;

  /// [errorMessage] is not preserved between copies.
  IssueState copyWith({
    IssueStatus? status,
    String? rentalId,
    List<IssueModel>? issues,
    IssueFilter? filter,
    String? errorMessage,
  }) =>
      IssueState(
        status: status ?? this.status,
        rentalId: rentalId ?? this.rentalId,
        issues: issues ?? this.issues,
        filter: filter ?? this.filter,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, rentalId, issues, filter, errorMessage];
}
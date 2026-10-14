import 'package:equatable/equatable.dart';

enum IssueFormStatus { editing, saving, done, failure }

final class IssueFormState extends Equatable {
  const IssueFormState({
    this.status = IssueFormStatus.editing,
    this.photoName,
    this.errorMessage,
  });

  final IssueFormStatus status;
  final String? photoName;
  final String? errorMessage;

  IssueFormState copyWith({
    IssueFormStatus? status,
    String? photoName,
    bool clearPhoto = false,
    String? errorMessage,
  }) =>
      IssueFormState(
        status: status ?? this.status,
        photoName: clearPhoto ? null : (photoName ?? this.photoName),
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, photoName, errorMessage];
}
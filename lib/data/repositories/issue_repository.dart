import '../local/issue_dao.dart';
import '../models/issue_model.dart';
import '../models/issue_severity.dart';

class IssueRepository {
  const IssueRepository(this._dao);

  final IssueDao _dao;

  Future<List<IssueModel>> getIssues(
      String rentalId, {
        String? room,
        IssueSeverity? severity,
        String? query,
      }) =>
      _dao.getByRental(
        rentalId,
        room: room,
        severity: severity,
        query: query,
      );

  Future<IssueModel?> getIssue(String id) => _dao.getById(id);

  Future<int> countByRental(String rentalId) => _dao.countByRental(rentalId);

  Future<void> addIssue(IssueModel issue) => _dao.insert(issue);

  Future<void> updateIssue(IssueModel issue) =>
      _dao.update(issue.copyWith(updatedAt: DateTime.now()));

  Future<void> deleteIssue(String id) => _dao.delete(id);
}
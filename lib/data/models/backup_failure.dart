/// An error whose message is safe to show directly to the user.
class BackupFailure implements Exception {
  const BackupFailure(this.message);

  final String message;

  @override
  String toString() => 'BackupFailure($message)';
}
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../models/backup_failure.dart';
import '../models/issue_model.dart';
import '../models/issue_severity.dart';
import '../models/issue_stage.dart';
import '../models/rental_model.dart';

class BackupRemoteSource {
  const BackupRemoteSource(this._client);

  final SupabaseClient? _client;

  static const String _rentalsTable = 'rentals';
  static const String _issuesTable = 'issues';
  static const String _bucket = 'issue-photos';

  static const int _pageSize = 500;
  static const int _chunkSize = 100;
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _fileTimeout = Duration(seconds: 90);

  bool get isAvailable => _client != null;

  String? get userId => _client?.auth.currentUser?.id;

  String requireUserId() {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const BackupFailure(AppStrings.backupSignInRequired);
    return id;
  }

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw const BackupFailure(AppStrings.backupUnavailable);
    return client;
  }

  // ---------------------------------------------------------------- rows

  Future<List<RentalModel>> fetchRentals() async {
    final rows = await _selectAll(_rentalsTable);
    return rows.map(_rentalFromRow).toList();
  }

  Future<List<IssueModel>> fetchIssues() async {
    final rows = await _selectAll(_issuesTable);
    return rows.map(_issueFromRow).toList();
  }

  Future<void> upsertRentals(List<RentalModel> rentals) =>
      _upsert(_rentalsTable, rentals.map(_rentalToRow).toList());

  Future<void> upsertIssues(List<IssueModel> issues) =>
      _upsert(_issuesTable, issues.map(_issueToRow).toList());

  /// Deleting a rental also deletes its issues in the cloud (cascade).
  Future<void> deleteRentals(List<String> ids) => _delete(_rentalsTable, ids);

  Future<void> deleteIssues(List<String> ids) => _delete(_issuesTable, ids);

  Future<List<Map<String, dynamic>>> _selectAll(String table) async {
    final rows = <Map<String, dynamic>>[];
    var from = 0;
    while (true) {
      final page = await _run(
            () => _db
            .from(table)
            .select()
            .order('id')
            .range(from, from + _pageSize - 1),
      );
      rows.addAll(page);
      if (page.length < _pageSize) return rows;
      from += _pageSize;
    }
  }

  Future<void> _upsert(String table, List<Map<String, dynamic>> rows) async {
    for (final chunk in _chunks(rows)) {
      await _run(() => _db.from(table).upsert(chunk, onConflict: 'id'));
    }
  }

  Future<void> _delete(String table, List<String> ids) async {
    for (final chunk in _chunks(ids)) {
      await _run(() => _db.from(table).delete().inFilter('id', chunk));
    }
  }

  // -------------------------------------------------------------- photos

  Future<void> uploadPhoto({
    required String userId,
    required String name,
    required File file,
  }) {
    return _run(
          () => _db.storage.from(_bucket).upload(
        '$userId/$name',
        file,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _contentType(name),
        ),
      ),
      timeout: _fileTimeout,
    );
  }

  Future<Uint8List> downloadPhoto({
    required String userId,
    required String name,
  }) {
    return _run(
          () => _db.storage.from(_bucket).download('$userId/$name'),
      timeout: _fileTimeout,
    );
  }

  Future<void> removePhotos(String userId, List<String> names) async {
    for (final chunk in _chunks(names)) {
      final paths = chunk.map((name) => '$userId/$name').toList();
      await _run(() => _db.storage.from(_bucket).remove(paths));
    }
  }

  // ------------------------------------------------------------- helpers

  Iterable<List<T>> _chunks<T>(List<T> items) sync* {
    for (var i = 0; i < items.length; i += _chunkSize) {
      yield items.sublist(i, min(i + _chunkSize, items.length));
    }
  }

  Future<T> _run<T>(
      Future<T> Function() action, {
        Duration timeout = _timeout,
      }) async {
    try {
      return await action().timeout(timeout);
    } on BackupFailure {
      rethrow;
    } on PostgrestException catch (error) {
      final known = _knownPostgrestFailure(error);
      if (known != null) throw known;
      rethrow;
    } on StorageException catch (error) {
      final known = _knownStorageFailure(error);
      if (known != null) throw known;
      rethrow;
    } on AuthException {
      throw const BackupFailure(AppStrings.backupSessionExpired);
    } catch (error) {
      if (_isNetworkError(error)) {
        throw const BackupFailure(AppStrings.backupNetworkError);
      }
      rethrow;
    }
  }

  static BackupFailure? _knownPostgrestFailure(PostgrestException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();

    if (code == '42P01' ||
        code == 'PGRST205' ||
        (code == '42501' && message.contains('permission denied'))) {
      return const BackupFailure(AppStrings.backupNotSetUp);
    }
    if (code == 'PGRST301' || code == 'PGRST303' || message.contains('jwt')) {
      return const BackupFailure(AppStrings.backupSessionExpired);
    }
    return null;
  }

  static BackupFailure? _knownStorageFailure(StorageException error) {
    final status = error.statusCode?.toString();
    final message = error.message.toLowerCase();

    if (message.contains('bucket not found') ||
        message.contains('row-level security') ||
        status == '403') {
      return const BackupFailure(AppStrings.backupNotSetUp);
    }
    if (message.contains('jwt') || status == '401') {
      return const BackupFailure(AppStrings.backupSessionExpired);
    }
    return null;
  }

  static bool _isNetworkError(Object error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HandshakeException) {
      return true;
    }
    final text = error.toString().toLowerCase();
    return text.contains('clientexception') ||
        text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection');
  }

  static String _contentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  // Dates are stored in UTC in the cloud and converted back to local time.
  static String _utc(DateTime date) => date.toUtc().toIso8601String();

  static DateTime _local(Object? value) =>
      DateTime.parse(value as String).toLocal();

  static Map<String, dynamic> _rentalToRow(RentalModel rental) => {
    'id': rental.id,
    'name': rental.name,
    'address': rental.address,
    'lease_start': _utc(rental.leaseStart),
    'lease_end': _utc(rental.leaseEnd),
    'created_at': _utc(rental.createdAt),
    'updated_at': _utc(rental.updatedAt),
  };

  static RentalModel _rentalFromRow(Map<String, dynamic> row) => RentalModel(
    id: row['id'] as String,
    name: row['name'] as String,
    address: row['address'] as String,
    leaseStart: _local(row['lease_start']),
    leaseEnd: _local(row['lease_end']),
    createdAt: _local(row['created_at']),
    updatedAt: _local(row['updated_at']),
  );

  static Map<String, dynamic> _issueToRow(IssueModel issue) => {
    'id': issue.id,
    'rental_id': issue.rentalId,
    'title': issue.title,
    'room': issue.room,
    'severity': issue.severity.name,
    'stage': issue.stage.name,
    'note': issue.note,
    'photo_path': issue.photoPath,
    'created_at': _utc(issue.createdAt),
    'updated_at': _utc(issue.updatedAt),
  };

  static IssueModel _issueFromRow(Map<String, dynamic> row) => IssueModel(
    id: row['id'] as String,
    rentalId: row['rental_id'] as String,
    title: row['title'] as String,
    room: row['room'] as String,
    severity: IssueSeverity.fromName(row['severity'] as String),
    stage: IssueStage.fromName(row['stage'] as String),
    note: row['note'] as String?,
    photoPath: row['photo_path'] as String?,
    createdAt: _local(row['created_at']),
    updatedAt: _local(row['updated_at']),
  );
}
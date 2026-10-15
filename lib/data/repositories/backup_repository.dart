import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_strings.dart';
import '../../services/image/image_service.dart';
import '../../services/preferences_service.dart';
import '../models/backup_failure.dart';
import '../models/backup_summary.dart';
import '../models/issue_model.dart';
import '../remote/backup_remote_source.dart';
import 'issue_repository.dart';
import 'rental_repository.dart';

typedef ProgressCallback = void Function(String message);

/// Keeps the local SQLite database and the Supabase backup in step.
///
/// SQLite is always the source of truth:
/// - [backUp] pushes newer local rows (and photos) to the cloud, and removes
///   cloud rows that were deleted on this device after being backed up.
/// - [restore] pulls newer cloud rows (and missing photos) onto this device
///   and never deletes anything locally.
/// When the same row exists on both sides, the newest `updatedAt` wins.
class BackupRepository {
  BackupRepository({
    required BackupRemoteSource remote,
    required RentalRepository rentals,
    required IssueRepository issues,
    required ImageService images,
    required PreferencesService preferences,
  })  : _remote = remote,
        _rentals = rentals,
        _issues = issues,
        _images = images,
        _preferences = preferences;

  final BackupRemoteSource _remote;
  final RentalRepository _rentals;
  final IssueRepository _issues;
  final ImageService _images;
  final PreferencesService _preferences;

  static const String _rentalKind = 'rental';
  static const String _issueKind = 'issue';

  bool get isAvailable => _remote.isAvailable;

  DateTime? get lastBackup {
    final userId = _remote.userId;
    return userId == null ? null : _preferences.lastBackup(userId);
  }

  // -------------------------------------------------------------- backup

  Future<BackupSummary> backUp({ProgressCallback? onProgress}) async {
    final userId = _remote.requireUserId();
    void report(String message) => onProgress?.call(message);

    report(AppStrings.backupChecking);
    final remoteRentals = {
      for (final rental in await _remote.fetchRentals()) rental.id: rental,
    };
    final remoteIssues = {
      for (final issue in await _remote.fetchIssues()) issue.id: issue,
    };
    final localRentals = await _rentals.getRentals();
    final localIssues = await _issues.getAllIssues();

    // 1. Rentals that are new or newer than the cloud copy.
    final rentalsToPush = localRentals.where((rental) {
      final remote = remoteRentals[rental.id];
      return remote == null || rental.updatedAt.isAfter(remote.updatedAt);
    }).toList();
    await _remote.upsertRentals(rentalsToPush);

    // 2. Issues (and the photos they need) that are new or newer.
    final issuesToPush = localIssues.where((issue) {
      final remote = remoteIssues[issue.id];
      return remote == null || issue.updatedAt.isAfter(remote.updatedAt);
    }).toList();

    final payload = <IssueModel>[];
    final uploads = <String>{};
    final staleCloudPhotos = <String>{};

    for (final issue in issuesToPush) {
      final remote = remoteIssues[issue.id];
      final name = issue.photoPath;
      String? sendName;

      if (name != null && _isSafeName(name)) {
        if (remote?.photoPath == name) {
          sendName = name; // already in the cloud
        } else if (await _images.fileFor(name).exists()) {
          sendName = name;
          uploads.add(name);
        }
      }

      final oldCloudPhoto = remote?.photoPath;
      if (oldCloudPhoto != null && oldCloudPhoto != sendName) {
        staleCloudPhotos.add(oldCloudPhoto);
      }
      payload.add(_withPhoto(issue, sendName));
    }

    var uploaded = 0;
    for (final name in uploads) {
      report(AppStrings.backupUploadingPhotos(++uploaded, uploads.length));
      await _remote.uploadPhoto(
        userId: userId,
        name: name,
        file: _images.fileFor(name),
      );
    }
    await _remote.upsertIssues(payload);

    // 3. Deletions: only items this device already backed up before.
    final localRentalIds = {for (final r in localRentals) r.id};
    final localIssueIds = {for (final i in localIssues) i.id};

    final deletedRentalIds = _preferences
        .syncedIds(userId, _rentalKind)
        .difference(localRentalIds)
        .intersection(remoteRentals.keys.toSet());
    final deletedIssueIds = _preferences
        .syncedIds(userId, _issueKind)
        .difference(localIssueIds)
        .intersection(remoteIssues.keys.toSet());

    final doomedIssues = remoteIssues.values.where(
          (issue) =>
      deletedIssueIds.contains(issue.id) ||
          deletedRentalIds.contains(issue.rentalId),
    );
    staleCloudPhotos.addAll(
      doomedIssues.map((issue) => issue.photoPath).whereType<String>(),
    );

    final doomedIssueIds = doomedIssues.map((issue) => issue.id).toList();
    if (doomedIssueIds.isNotEmpty) await _remote.deleteIssues(doomedIssueIds);
    if (deletedRentalIds.isNotEmpty) {
      await _remote.deleteRentals(deletedRentalIds.toList());
    }

    // Cleaning up orphaned cloud photos is best effort.
    final stale = staleCloudPhotos.where(_isSafeName).toList();
    if (stale.isNotEmpty) {
      try {
        await _remote.removePhotos(userId, stale);
      } catch (error) {
        debugPrint('BackupRepository: could not remove old photos ($error)');
      }
    }

    await _preferences.setSyncedIds(userId, _rentalKind, localRentalIds);
    await _preferences.setSyncedIds(userId, _issueKind, localIssueIds);
    await _preferences.setLastBackup(userId, DateTime.now());

    return BackupSummary(
      rentals: rentalsToPush.length,
      issues: issuesToPush.length,
      photos: uploads.length,
      removed: deletedRentalIds.length + deletedIssueIds.length,
    );
  }

  // ------------------------------------------------------------- restore

  Future<BackupSummary> restore({ProgressCallback? onProgress}) async {
    final userId = _remote.requireUserId();
    void report(String message) => onProgress?.call(message);

    report(AppStrings.restoreReading);
    final remoteRentals = await _remote.fetchRentals();
    final remoteIssues = await _remote.fetchIssues();
    final localRentals = {
      for (final rental in await _rentals.getRentals()) rental.id: rental,
    };
    final localIssues = {
      for (final issue in await _issues.getAllIssues()) issue.id: issue,
    };

    final rentalsToSave = remoteRentals.where((rental) {
      final local = localRentals[rental.id];
      return local == null || rental.updatedAt.isAfter(local.updatedAt);
    }).toList();

    // An issue can only be saved if its rental exists on this device.
    final knownRentalIds = {
      ...localRentals.keys,
      ...rentalsToSave.map((rental) => rental.id),
    };
    final issuesToSave = remoteIssues.where((issue) {
      if (!knownRentalIds.contains(issue.rentalId)) return false;
      final local = localIssues[issue.id];
      return local == null || issue.updatedAt.isAfter(local.updatedAt);
    }).toList();

    // Photos that the restored (or already matching) issues need.
    final savingIds = {for (final issue in issuesToSave) issue.id};
    final toDownload = <String>{};
    for (final issue in remoteIssues) {
      final name = issue.photoPath;
      if (name == null || !_isSafeName(name)) continue;
      final inUse = savingIds.contains(issue.id) ||
          localIssues[issue.id]?.photoPath == name;
      if (inUse && !await _images.fileFor(name).exists()) {
        toDownload.add(name);
      }
    }

    var downloaded = 0;
    var failed = 0;
    var index = 0;
    for (final name in toDownload) {
      report(AppStrings.restoreDownloadingPhotos(++index, toDownload.length));
      try {
        final bytes = await _remote.downloadPhoto(userId: userId, name: name);
        await _images.fileFor(name).writeAsBytes(bytes, flush: true);
        downloaded++;
      } on BackupFailure {
        rethrow; // connection or session problem: stop and tell the user
      } catch (error) {
        failed++; // one missing photo must not stop the restore
        debugPrint('BackupRepository: photo $name failed ($error)');
      }
    }

    report(AppStrings.restoreSaving);
    await _rentals.restoreRentals(rentalsToSave);
    await _issues.restoreIssues(issuesToSave);

    // Remove local photo files that a restored issue no longer uses.
    for (final issue in issuesToSave) {
      final oldName = localIssues[issue.id]?.photoPath;
      if (oldName != null && oldName != issue.photoPath) {
        await _images.delete(oldName);
      }
    }

    await _preferences.setSyncedIds(userId, _rentalKind, {
      ..._preferences.syncedIds(userId, _rentalKind),
      ...remoteRentals.map((rental) => rental.id),
    });
    await _preferences.setSyncedIds(userId, _issueKind, {
      ..._preferences.syncedIds(userId, _issueKind),
      ...remoteIssues.map((issue) => issue.id),
    });

    return BackupSummary(
      rentals: rentalsToSave.length,
      issues: issuesToSave.length,
      photos: downloaded,
      photoFailures: failed,
    );
  }

  // ------------------------------------------------------------- helpers

  /// Photo names come from the cloud, so never trust them as file paths.
  bool _isSafeName(String name) =>
      name.isNotEmpty &&
          p.basename(name) == name &&
          !name.contains('..') &&
          !name.contains(r'\');

  /// Built directly (not with copyWith) so the photo can become null.
  IssueModel _withPhoto(IssueModel issue, String? photoPath) => IssueModel(
    id: issue.id,
    rentalId: issue.rentalId,
    title: issue.title,
    room: issue.room,
    severity: issue.severity,
    stage: issue.stage,
    note: issue.note,
    photoPath: photoPath,
    createdAt: issue.createdAt,
    updatedAt: issue.updatedAt,
  );
}
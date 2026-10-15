import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_strings.dart';
import '../data/repositories/rental_repository.dart';

/// Schedules local "lease ending" reminders. Works fully offline.
/// Reads rentals straight from the repository, so a filtered search
/// list can never cancel reminders by mistake.
class ReminderService {
  ReminderService(this._rentals);

  final RentalRepository _rentals;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _running = false;
  bool _pending = false;

  /// Days before the lease end date. Fired at [_hour]:00 local time.
  static const List<int> _daysBefore = [30, 7, 1];
  static const int _hour = 9;

  Future<void> init() async {
    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _ready = true;
    } catch (error, stackTrace) {
      debugPrint('ReminderService: init failed ($error)');
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  /// Cancels everything and schedules again from the saved rentals.
  /// Calls that arrive while a sync is running are merged into one rerun.
  Future<void> sync() async {
    if (!_ready) return;
    if (_running) {
      _pending = true;
      return;
    }
    _running = true;
    try {
      do {
        _pending = false;
        await _syncOnce();
      } while (_pending);
    } finally {
      _running = false;
    }
  }

  Future<void> _syncOnce() async {
    try {
      final rentals = await _rentals.getRentals();
      await _plugin.cancelAll();

      final now = DateTime.now();
      var id = 0;
      var permissionAsked = false;

      for (final rental in rentals) {
        final end = rental.leaseEnd;

        for (final days in _daysBefore) {
          // DateTime rolls a negative day back into the previous month.
          final when = DateTime(end.year, end.month, end.day - days, _hour);
          if (!when.isAfter(now)) continue;

          if (!permissionAsked) {
            permissionAsked = true;
            if (!await _requestPermission()) return;
          }

          await _schedule(
            id: id++,
            when: when,
            body: _body(rental.name, days),
          );
        }
      }
    } catch (error, stackTrace) {
      // A reminder failure must never crash the app.
      debugPrint('ReminderService: sync failed ($error)');
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  /// Debug only: fires a test notification after [delay].
  Future<void> debugRemindIn(Duration delay) async {
    if (!kDebugMode || !_ready) return;
    if (!await _requestPermission()) return;
    await _schedule(
      id: 9999,
      when: DateTime.now().add(delay),
      body: 'Test reminder',
    );
  }

  Future<bool> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required String body,
  }) {
    return _plugin.zonedSchedule(
      id,
      AppStrings.reminderTitle,
      body,
      // Same instant as the local DateTime, so no timezone lookup is needed.
      tz.TZDateTime.from(when, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lease_reminders',
          'Lease reminders',
          channelDescription: 'Reminders before your lease ends',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  String _body(String name, int days) {
    final when = days == 1 ? 'tomorrow' : 'in $days days';
    return '$name ends $when. Take move-out photos and review your deposit.';
  }
}

import 'package:flutter/cupertino.dart';

import '../core/config/app_flags.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_strings.dart';
import '../data/repositories/rental_repository.dart';

class ReminderService {
  ReminderService(this._rentals);

  final RentalRepository _rentals;
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _ready = false;

  String? _lastSignature;
  bool _running = false;
  bool _pending = false;

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

      final signature = rentals
          .map((r) => '${r.id}|${r.name}|${r.leaseEnd.toIso8601String()}')
          .join(';');
      if (signature == _lastSignature) {
        debugPrint('ReminderService: no changes, skipped');
        return;
      }

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

      _lastSignature = signature;
      debugPrint('ReminderService: scheduled $id reminder(s)');
    } catch (error, stackTrace) {
      // A reminder failure must never crash the app.
      debugPrint('ReminderService: sync failed ($error)');
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  /// Debug only: fires a test notification after [delay].
  Future<void> debugRemindIn(Duration delay) async {
    if (!AppFlags.showQaTools || !_ready) return;
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

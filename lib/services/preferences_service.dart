import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value settings stored on the device.
class PreferencesService {
  const PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeKey = 'theme_mode';
  static const String _onboardingKey = 'onboarding_done';

  ThemeMode get themeMode {
    final saved = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  bool get onboardingDone => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(_onboardingKey, value);

  // Cloud backup bookkeeping, kept separately for each signed-in user.

  DateTime? lastBackup(String userId) {
    final raw = _prefs.getString('last_backup_$userId');
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }

  Future<void> setLastBackup(String userId, DateTime time) => _prefs.setString(
    'last_backup_$userId',
    time.toUtc().toIso8601String(),
  );

  /// Ids this device has already backed up. Used to detect deletions.
  Set<String> syncedIds(String userId, String kind) =>
      (_prefs.getStringList('synced_${kind}_$userId') ?? const <String>[])
          .toSet();

  Future<void> setSyncedIds(String userId, String kind, Set<String> ids) =>
      _prefs.setStringList('synced_${kind}_$userId', ids.toList());

}
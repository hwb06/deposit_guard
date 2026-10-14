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
}
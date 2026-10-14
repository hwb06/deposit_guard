import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/preferences_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._preferences)
      : super(SettingsState(themeMode: _preferences.themeMode));

  final PreferencesService _preferences;

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _preferences.setThemeMode(mode);
  }

  Future<void> completeOnboarding() => _preferences.setOnboardingDone(true);

  Future<void> replayOnboarding() => _preferences.setOnboardingDone(false);
}
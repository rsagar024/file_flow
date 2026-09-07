import 'package:equatable/equatable.dart';
import 'package:fileflow/core/services/theme_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemePreferencesService _themePreferencesService;

  ThemeCubit(this._themePreferencesService) : super(const ThemeState()) {
    _loadPersistedMode();
  }

  Future<void> _loadPersistedMode() async {
    final persistedMode = await _themePreferencesService.readThemeMode();
    if (persistedMode != null) {
      emit(state.copyWith(mode: persistedMode));
    }
  }

  Future<void> updateMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _themePreferencesService.writeThemeMode(mode);
  }
}

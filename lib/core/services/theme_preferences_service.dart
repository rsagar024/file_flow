import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemePreferencesService {
  static const _themeModeKey = 'theme_mode';

  final FlutterSecureStorage _secureStorage;

  ThemePreferencesService({FlutterSecureStorage? secureStorage}) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<ThemeMode?> readThemeMode() async {
    final value = await _secureStorage.read(key: _themeModeKey);
    if (value == null) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }

  Future<void> writeThemeMode(ThemeMode mode) {
    return _secureStorage.write(key: _themeModeKey, value: mode.name);
  }
}

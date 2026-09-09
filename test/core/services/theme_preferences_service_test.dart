import 'package:fileflow/core/services/theme_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late ThemePreferencesService service;

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = ThemePreferencesService(secureStorage: mockStorage);
  });

  group('readThemeMode', () {
    test('maps a stored mode name back to the matching ThemeMode', () async {
      when(() => mockStorage.read(key: 'theme_mode')).thenAnswer((_) async => 'dark');

      final result = await service.readThemeMode();

      expect(result, ThemeMode.dark);
    });

    test('returns null when nothing has been stored', () async {
      when(() => mockStorage.read(key: 'theme_mode')).thenAnswer((_) async => null);

      final result = await service.readThemeMode();

      expect(result, isNull);
    });

    test('returns null when the stored value does not match any ThemeMode', () async {
      when(() => mockStorage.read(key: 'theme_mode')).thenAnswer((_) async => 'not-a-mode');

      final result = await service.readThemeMode();

      expect(result, isNull);
    });
  });

  group('writeThemeMode', () {
    test('persists the mode name under the theme_mode key', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((_) async {});

      await service.writeThemeMode(ThemeMode.light);

      verify(() => mockStorage.write(key: 'theme_mode', value: 'light')).called(1);
    });
  });
}

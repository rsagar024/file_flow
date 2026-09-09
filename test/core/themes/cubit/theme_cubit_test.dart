import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fileflow/core/themes/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockThemePreferencesService themePreferencesService;

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    themePreferencesService = MockThemePreferencesService();
  });

  group('construction / persisted mode load', () {
    blocTest<ThemeCubit, ThemeState>(
      'loads the persisted theme mode on construction when one exists',
      build: () {
        when(
          () => themePreferencesService.readThemeMode(),
        ).thenAnswer((_) async => ThemeMode.dark);
        return ThemeCubit(themePreferencesService);
      },
      wait: const Duration(milliseconds: 20),
      expect: () => [const ThemeState(mode: ThemeMode.dark)],
      verify: (_) {
        verify(() => themePreferencesService.readThemeMode()).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeState>(
      'keeps the default ThemeMode.system when no persisted mode exists',
      build: () {
        when(
          () => themePreferencesService.readThemeMode(),
        ).thenAnswer((_) async => null);
        return ThemeCubit(themePreferencesService);
      },
      wait: const Duration(milliseconds: 20),
      expect: () => <ThemeState>[],
      verify: (cubit) {
        expect(cubit.state.mode, ThemeMode.system);
      },
    );
  });

  group('updateMode', () {
    blocTest<ThemeCubit, ThemeState>(
      'emits the new mode and persists it via writeThemeMode',
      build: () {
        when(
          () => themePreferencesService.readThemeMode(),
        ).thenAnswer((_) async => null);
        when(
          () => themePreferencesService.writeThemeMode(any()),
        ).thenAnswer((_) async {});
        return ThemeCubit(themePreferencesService);
      },
      act: (cubit) => cubit.updateMode(ThemeMode.light),
      expect: () => [const ThemeState(mode: ThemeMode.light)],
      verify: (_) {
        verify(
          () => themePreferencesService.writeThemeMode(ThemeMode.light),
        ).called(1);
      },
    );

    test(
      'emits the new mode BEFORE the persistence write resolves '
      '(emit-then-persist ordering)',
      () async {
        final writeCompleter = Completer<void>();
        when(
          () => themePreferencesService.readThemeMode(),
        ).thenAnswer((_) async => null);
        when(
          () => themePreferencesService.writeThemeMode(any()),
        ).thenAnswer((_) => writeCompleter.future);

        final cubit = ThemeCubit(themePreferencesService);
        await Future.delayed(const Duration(milliseconds: 10));

        final updateFuture = cubit.updateMode(ThemeMode.dark);

        // The write hasn't resolved yet (writeCompleter is still pending),
        // but the state should already reflect the new mode because the
        // source code calls emit() before awaiting writeThemeMode().
        await Future.delayed(Duration.zero);
        expect(cubit.state.mode, ThemeMode.dark);
        verify(
          () => themePreferencesService.writeThemeMode(ThemeMode.dark),
        ).called(1);

        writeCompleter.complete();
        await updateFuture;

        await cubit.close();
      },
    );
  });
}

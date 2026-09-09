import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/core/themes/semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_connectivity_platform.dart';

/// Pumps [child] inside a minimal `MaterialApp` that provides everything the
/// app's base widgets/extensions require:
///  - `AppRoute.navigatorKey` wired in, since `CustomSnackbar`/the base
///    widgets' connectivity-change handler force-unwraps
///    `navigatorKey.currentState!.overlay!`.
///  - `SemanticColors` registered as a theme extension (light + dark), since
///    `context.colors` force-unwraps `Theme.of(this).extension<SemanticColors>()`.
///  - A [FakeConnectivityPlatform] installed, since `FileFlowState`/
///    `FileFlowBackgroundState` call `Connectivity().checkConnectivity()` and
///    subscribe to `Connectivity().onConnectivityChanged` on init.
///
/// Returns the installed [FakeConnectivityPlatform] so tests can drive
/// connectivity-change scenarios via `.emit(...)`.
Future<FakeConnectivityPlatform> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<BlocProvider<dynamic>> providers = const [],
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final fakeConnectivity = FakeConnectivityPlatform.install();

  final app = MaterialApp(
    navigatorKey: AppRoute.navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: const [SemanticColors.light]),
    darkTheme: ThemeData(extensions: const [SemanticColors.dark]),
    themeMode: themeMode,
    home: child,
  );

  // `MultiBlocProvider`/`Nested` asserts its `providers` list is non-empty,
  // so only wrap with it when the caller actually supplied providers.
  await tester.pumpWidget(
    providers.isEmpty ? app : MultiBlocProvider(providers: providers, child: app),
  );

  return fakeConnectivity;
}

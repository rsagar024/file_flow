import 'package:fileflow/core/themes/semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_connectivity_platform.dart';

/// Pumps [router] inside a `MaterialApp.router`, for tests that need to
/// assert real go_router navigation (`context.push`/`context.go`) rather
/// than `pumpApp`'s single-route `MaterialApp`.
///
/// Mirrors `pumpApp`'s setup (`SemanticColors` registered, a faked
/// connectivity platform installed) so screens built on
/// `FileFlowState`/`FileFlowBackgroundState` don't crash. Callers should give
/// [router] a `navigatorKey: AppRoute.navigatorKey` so `CustomSnackbar`'s
/// force-unwrap of it keeps working the same way it does under `pumpApp`.
Future<FakeConnectivityPlatform> pumpRouterApp(
  WidgetTester tester,
  GoRouter router, {
  List<BlocProvider<dynamic>> providers = const [],
}) async {
  final fakeConnectivity = FakeConnectivityPlatform.install();

  final app = MaterialApp.router(
    routerConfig: router,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: const [SemanticColors.light]),
    darkTheme: ThemeData(extensions: const [SemanticColors.dark]),
  );

  await tester.pumpWidget(
    providers.isEmpty ? app : MultiBlocProvider(providers: providers, child: app),
  );

  return fakeConnectivity;
}

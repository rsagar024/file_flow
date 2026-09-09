import 'package:fileflow/main.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/fake_connectivity_platform.dart';

/// Installs a [FakeConnectivityPlatform] (every `FileFlowState`/
/// `FileFlowBackgroundState`-based screen calls `Connectivity().checkConnectivity()`
/// on init) and pumps the real `FileFlowApp` — exercising the actual
/// `AppRoute.routes`, `AppRoute.navigatorKey`, and both
/// `BlocProvider<AuthBloc>`/`BlocProvider<ThemeCubit>` exactly as `main()`
/// wires them, rather than a stub router.
///
/// `getIt` must already be populated via `setUpIntegrationDi()` (NOT
/// `initDependencies()`, which touches real Firebase) before calling this,
/// and any usecase touched by `SplashScreen`'s initState-dispatched
/// `AuthCheckStatusEvent` (i.e. `checkAuthStatusUsecase`) must be stubbed
/// BEFORE this pump, since that event fires synchronously during
/// `tester.pumpWidget`. Call this from inside `mockNetworkImagesFor(() async
/// {...})` wrapping the whole test body, since `ProfileScreen`/`UserAvatar`
/// reload network images on every rebuild.
Future<FakeConnectivityPlatform> pumpFileFlowApp(WidgetTester tester) async {
  final fakeConnectivity = FakeConnectivityPlatform.install();
  await tester.pumpWidget(const FileFlowApp());
  return fakeConnectivity;
}

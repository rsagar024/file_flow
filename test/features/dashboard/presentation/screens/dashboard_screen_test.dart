import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/core/themes/cubit/theme_cubit.dart';
import 'package:fileflow/core/themes/semantic_colors.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:fileflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:fileflow/features/upload/presentation/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/dashboard_interactions.dart';
import '../../../../helpers/fake_connectivity_platform.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

/// Builds a real [AuthBloc] wired with fresh mocked usecases (same
/// constructor shape as `auth_bloc_test.dart`), stubbed so that a later
/// `OtpVerifyEvent` (dispatched via [_authenticate]) resolves to an
/// authenticated state carrying [user] — giving the embedded `ProfileScreen`
/// tab a non-null `state.user` to render.
///
/// This is deliberately synchronous and does NOT itself drive the bloc:
/// under `testWidgets`, time only advances via `tester.pump(...)`, so
/// awaiting a bare `Future.delayed` before anything has been pumped would
/// hang forever (`testWidgets` runs inside a `FakeAsync` zone whose clock
/// nothing is advancing yet).
AuthBloc _buildAuthBloc({
  UserEntity user = const UserEntity(uid: 'uid-1', displayName: 'Jane Doe'),
  // Empty device id short-circuits AuthBloc._startDeviceEnforcement before it
  // subscribes to watchCurrentDeviceActiveStatusUsecase, avoiding a
  // background StreamSubscription whose cancellation hangs SignOutEvent
  // handling under AutomatedTestWidgetsFlutterBinding.
  bool suppressDeviceEnforcement = false,
}) {
  final sendOtpUsecase = MockSendOtpUsecase();
  final verifyOtpUsecase = MockVerifyOtpUsecase();
  final resendOtpUsecase = MockResendOtpUsecase();
  final checkAuthStatusUsecase = MockCheckAuthStatusUsecase();
  final createAccountUsecase = MockCreateAccountUsecase();
  final signOutUsecase = MockSignOutUsecase();
  final getCurrentDeviceIdUsecase = MockGetCurrentDeviceIdUsecase();
  final watchCurrentDeviceActiveStatusUsecase = MockWatchCurrentDeviceActiveStatusUsecase();
  final signOutLocalOnlyUsecase = MockSignOutLocalOnlyUsecase();
  final updateProfileUsecase = MockUpdateProfileUsecase();

  when(() => getCurrentDeviceIdUsecase(any())).thenAnswer(
    (_) async => Right(suppressDeviceEnforcement ? '' : 'device-1'),
  );
  when(() => watchCurrentDeviceActiveStatusUsecase(any())).thenAnswer((_) => const Stream<bool>.empty());
  when(() => signOutLocalOnlyUsecase(any())).thenAnswer((_) async => const Right(null));
  when(() => signOutUsecase(any())).thenAnswer((_) async => const Right(null));
  when(() => verifyOtpUsecase(any())).thenAnswer(
    (_) async => Right(
      AuthResult(uid: user.uid ?? '', phoneNumber: '+10000000000', isNewUser: false, existingUser: user),
    ),
  );

  return AuthBloc(
    sendOtpUsecase,
    verifyOtpUsecase,
    resendOtpUsecase,
    checkAuthStatusUsecase,
    createAccountUsecase,
    signOutUsecase,
    getCurrentDeviceIdUsecase,
    watchCurrentDeviceActiveStatusUsecase,
    signOutLocalOnlyUsecase,
    updateProfileUsecase,
  );
}

/// Drives [bloc] (already pumped into the widget tree via [tester]) to an
/// authenticated state by dispatching a real `OtpVerifyEvent`, advancing the
/// fake test clock via `tester.pump(...)` instead of a bare `Future.delayed`.
Future<void> _authenticate(WidgetTester tester, AuthBloc bloc) async {
  bloc.add(const OtpVerifyEvent(otp: '123456'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(bloc.state.status, AuthAppStatus.authenticated);
}

/// A `ThemeCubit` backed by a mocked `ThemePreferencesService` (no persisted
/// mode), needed because the embedded `ProfileScreen`'s "Appearance" row
/// reads `context.watch<ThemeCubit>()`.
ThemeCubit _buildThemeCubit() {
  final themePreferencesService = MockThemePreferencesService();
  when(() => themePreferencesService.readThemeMode()).thenAnswer((_) async => null);
  when(() => themePreferencesService.writeThemeMode(any())).thenAnswer((_) async {});
  return ThemeCubit(themePreferencesService);
}

void _registerThemeModeFallback() {
  registerFallbackValue(ThemeMode.system);
}

void main() {
  setUpAll(() {
    registerFallbackValues();
    _registerThemeModeFallback();
  });

  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
  });

  testWidgets('renders HomeScreen content by default (tab 0)', (tester) async {
    tolerateOverflowErrors();
    await mockNetworkImagesFor(() async {
      final authBloc = _buildAuthBloc();
      final themeCubit = _buildThemeCubit();
      addTearDown(authBloc.close);
      addTearDown(themeCubit.close);

      await pumpApp(
        tester,
        const DashboardScreen(),
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
      );
      await _authenticate(tester, authBloc);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text(StringConstants.kSearchInFileFlow), findsOneWidget);
    });
  });

  testWidgets('bottom nav switches tabs, and the FAB opens the Upload tab', (tester) async {
    tolerateOverflowErrors();
    await mockNetworkImagesFor(() async {
      final authBloc = _buildAuthBloc();
      final themeCubit = _buildThemeCubit();
      addTearDown(authBloc.close);
      addTearDown(themeCubit.close);

      await pumpApp(
        tester,
        const DashboardScreen(),
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
      );
      await _authenticate(tester, authBloc);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Sharing tab (nav label is unambiguous before the page is built).
      tapNavItem(tester, StringConstants.kSharing);
      await tester.pumpAndSettle();
      expect(find.text('Sharing'), findsWidgets);

      // "Coming Soon" tab (settings icon / kComing label).
      tapNavItem(tester, StringConstants.kComing);
      await tester.pumpAndSettle();
      expect(find.text('Coming Soon'), findsOneWidget);

      // Profile tab — asserted by type since both the nav label and the
      // screen's own app bar title are the literal string "Profile".
      tapNavItem(tester, StringConstants.kProfile);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Back to Home via the nav bar.
      tapNavItem(tester, StringConstants.kHome);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // There is no bottom-nav icon for the Upload tab (index 2) — it's only
      // reachable via the FAB, which also kicks off the ~20s fake loading
      // animation. A single pump (NOT pumpAndSettle) is required here since
      // the animation repeats indefinitely until the delay resolves.
      await tester.tap(fabFinder());
      await tester.pump();
      expect(find.byType(UploadScreen), findsOneWidget);
      expect(loadingSpinnerFinder(), findsOneWidget);

      // Resolve the FAB's fake 20s delay via the fake clock (not a real
      // wait) so the AnimationController stops and no ticker/timer leaks
      // past the end of this test.
      await tester.pump(const Duration(seconds: 20));
      expect(loadingSpinnerFinder(), findsNothing);
    });
  });

  testWidgets('tapping the FAB shows the loading indicator without waiting out the real delay', (tester) async {
    tolerateOverflowErrors();
    await mockNetworkImagesFor(() async {
      final authBloc = _buildAuthBloc();
      final themeCubit = _buildThemeCubit();
      addTearDown(authBloc.close);
      addTearDown(themeCubit.close);

      await pumpApp(
        tester,
        const DashboardScreen(),
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
      );
      await _authenticate(tester, authBloc);
      await tester.pumpAndSettle();

      expect(loadingSpinnerFinder(), findsNothing);

      await tester.tap(fabFinder());
      await tester.pump();

      expect(loadingSpinnerFinder(), findsOneWidget);

      // Advance Flutter's fake test clock by the real 20s delay instead of
      // actually waiting — this resolves `Future.delayed` and stops the
      // animation so the test can finish cleanly.
      await tester.pump(const Duration(seconds: 20));
      expect(loadingSpinnerFinder(), findsNothing);
    });
  });

  testWidgets('navigates to LoginScreen once the provided AuthBloc reaches unAuthenticated', (tester) async {
    tolerateOverflowErrors();
    await mockNetworkImagesFor(() async {
      final fakeConnectivity = FakeConnectivityPlatform.install();
      addTearDown(fakeConnectivity.dispose);

      final authBloc = _buildAuthBloc(suppressDeviceEnforcement: true);
      final themeCubit = _buildThemeCubit();
      addTearDown(authBloc.close);
      addTearDown(themeCubit.close);

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: DashboardScreen.routeName,
        routes: [
          GoRoute(path: DashboardScreen.routeName, builder: (context, state) => const DashboardScreen()),
          GoRoute(path: LoginScreen.routeName, builder: (context, state) => const LoginScreen()),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: ThemeData(extensions: const [SemanticColors.light]),
            darkTheme: ThemeData(extensions: const [SemanticColors.dark]),
          ),
        ),
      );
      await _authenticate(tester, authBloc);
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      authBloc.add(const SignOutEvent());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(authBloc.state.status, AuthAppStatus.unAuthenticated);

      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
    });
  });
}

import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/cubit/theme_cubit.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSendOtpUsecase sendOtpUsecase;
  late MockVerifyOtpUsecase verifyOtpUsecase;
  late MockResendOtpUsecase resendOtpUsecase;
  late MockCheckAuthStatusUsecase checkAuthStatusUsecase;
  late MockCreateAccountUsecase createAccountUsecase;
  late MockSignOutUsecase signOutUsecase;
  late MockGetCurrentDeviceIdUsecase getCurrentDeviceIdUsecase;
  late MockWatchCurrentDeviceActiveStatusUsecase watchCurrentDeviceActiveStatusUsecase;
  late MockSignOutLocalOnlyUsecase signOutLocalOnlyUsecase;
  late MockUpdateProfileUsecase updateProfileUsecase;
  late MockThemePreferencesService themePreferencesService;

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    sendOtpUsecase = MockSendOtpUsecase();
    verifyOtpUsecase = MockVerifyOtpUsecase();
    resendOtpUsecase = MockResendOtpUsecase();
    checkAuthStatusUsecase = MockCheckAuthStatusUsecase();
    createAccountUsecase = MockCreateAccountUsecase();
    signOutUsecase = MockSignOutUsecase();
    getCurrentDeviceIdUsecase = MockGetCurrentDeviceIdUsecase();
    watchCurrentDeviceActiveStatusUsecase = MockWatchCurrentDeviceActiveStatusUsecase();
    signOutLocalOnlyUsecase = MockSignOutLocalOnlyUsecase();
    updateProfileUsecase = MockUpdateProfileUsecase();
    themePreferencesService = MockThemePreferencesService();

    // Empty device id short-circuits AuthBloc._startDeviceEnforcement before
    // it subscribes to watchCurrentDeviceActiveStatusUsecase, avoiding a
    // background StreamSubscription whose cancellation later hangs SignOutEvent
    // handling under AutomatedTestWidgetsFlutterBinding.
    when(() => getCurrentDeviceIdUsecase(any())).thenAnswer((_) async => const Right(''));
    when(() => watchCurrentDeviceActiveStatusUsecase(any())).thenAnswer((_) => const Stream<bool>.empty());
    when(() => signOutLocalOnlyUsecase(any())).thenAnswer((_) async => const Right(null));
    when(() => signOutUsecase(any())).thenAnswer((_) async => const Right(null));
  });

  AuthBloc buildBloc() {
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

  // Uses `tester.pump(...)` rather than a raw `Future.delayed(...)` to let
  // AuthCheckStatusEvent's async handler chain resolve: under
  // AutomatedTestWidgetsFlutterBinding, Timers (which back Future.delayed)
  // only advance via the test's fake clock, so an un-pumped raw delay never
  // completes and hangs the test indefinitely.
  Future<AuthBloc> buildBlocWithUser(WidgetTester tester, UserEntity user) async {
    when(() => checkAuthStatusUsecase(any())).thenAnswer(
      (_) async => Right(AuthStatusResult(isLoggedIn: true, isNewUser: false, uid: user.uid, user: user)),
    );
    final bloc = buildBloc();
    bloc.add(AuthCheckStatusEvent());
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 20));
    return bloc;
  }

  ThemeCubit buildThemeCubit(ThemeMode? persistedMode) {
    when(() => themePreferencesService.readThemeMode()).thenAnswer((_) async => persistedMode);
    when(() => themePreferencesService.writeThemeMode(any())).thenAnswer((_) async {});
    return ThemeCubit(themePreferencesService);
  }

  Future<void> pumpProfileScreen(
    WidgetTester tester, {
    required AuthBloc authBloc,
    required ThemeCubit themeCubit,
  }) async {
    await pumpApp(
      tester,
      const ProfileScreen(),
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ThemeCubit>.value(value: themeCubit),
      ],
    );
    // Flush ThemeCubit's async persisted-mode load so the initial render
    // reflects the seeded mode deterministically.
    await tester.pump(const Duration(milliseconds: 20));
  }

  group('ProfileScreen — storage usage card', () {
    testWidgets('renders formatted used/limit bytes for a small usage fixture', (tester) async {
      const user = UserEntity(
        uid: 'uid-1',
        displayName: 'Jane Doe',
        username: 'janedoe',
        storageUsedBytes: 500 * 1024 * 1024,
        storageLimitBytes: 5 * 1024 * 1024 * 1024,
      );
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      final themeCubit = buildThemeCubit(ThemeMode.light);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      expect(find.text('500.0 MB / 5.0 GB'), findsOneWidget);
    });

    testWidgets('renders formatted used/limit bytes for a larger usage fixture', (tester) async {
      const user = UserEntity(
        uid: 'uid-2',
        displayName: 'John Roe',
        username: 'johnroe',
        storageUsedBytes: 2 * 1024 * 1024 * 1024,
        storageLimitBytes: 10 * 1024 * 1024 * 1024,
      );
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      final themeCubit = buildThemeCubit(ThemeMode.light);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      expect(find.text('2.0 GB / 10.0 GB'), findsOneWidget);
    });
  });

  group('ProfileScreen — sectioned items', () {
    testWidgets('renders account, preferences, and other sections', (tester) async {
      const user = UserEntity(uid: 'uid-1', displayName: 'Jane Doe', username: 'janedoe');
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      final themeCubit = buildThemeCubit(ThemeMode.light);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      expect(find.text(StringConstants.kAccount), findsOneWidget);
      expect(find.text(StringConstants.kPreferences), findsOneWidget);
      expect(find.text(StringConstants.kEditProfile), findsOneWidget);
      expect(find.text(StringConstants.kNotification), findsOneWidget);
      expect(find.text(StringConstants.kDevices), findsOneWidget);
      expect(find.text(StringConstants.kAppearance), findsOneWidget);
      expect(find.text(StringConstants.kRecycleBin), findsOneWidget);
      expect(find.text(StringConstants.kLogout), findsOneWidget);
    });
  });

  group('ProfileScreen — theme mode selector', () {
    testWidgets('reflects the current ThemeCubit mode', (tester) async {
      const user = UserEntity(uid: 'uid-1', displayName: 'Jane Doe', username: 'janedoe');
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      final themeCubit = buildThemeCubit(ThemeMode.dark);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      expect(themeCubit.state.mode, ThemeMode.dark);
      expect(find.text(StringConstants.kDarkMode), findsOneWidget);
    });

    testWidgets('tapping a same-brightness unselected segment updates the mode directly', (tester) async {
      const user = UserEntity(uid: 'uid-1', displayName: 'Jane Doe', username: 'janedoe');
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      // Seeded as light; "System Default" resolves to the same (light)
      // platform brightness in the test environment, so tapping it takes
      // the direct `updateMode` path rather than the cross-fade reveal
      // animation (which requires a differing resolved brightness).
      final themeCubit = buildThemeCubit(ThemeMode.light);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      // The theme selector sits below the default 800x600 test viewport, so
      // scroll it into view before tapping.
      await tester.ensureVisible(find.text(StringConstants.kSystemDefault));
      await tester.tap(find.text(StringConstants.kSystemDefault));
      await tester.pump();

      expect(themeCubit.state.mode, ThemeMode.system);
      verify(() => themePreferencesService.writeThemeMode(ThemeMode.system)).called(1);
    });
  });

  group('ProfileScreen — logout', () {
    testWidgets('cancelling the confirmation dialog does not dispatch SignOutEvent', (tester) async {
      const user = UserEntity(uid: 'uid-1', displayName: 'Jane Doe', username: 'janedoe');
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      final themeCubit = buildThemeCubit(ThemeMode.light);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      // The Logout row sits below the default 800x600 test viewport, so
      // scroll it into view before tapping.
      await tester.ensureVisible(find.widgetWithText(ListTile, StringConstants.kLogout));
      await tester.tap(find.widgetWithText(ListTile, StringConstants.kLogout));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => signOutUsecase(any()));
    });

    testWidgets('confirming the dialog dispatches SignOutEvent', (tester) async {
      const user = UserEntity(uid: 'uid-1', displayName: 'Jane Doe', username: 'janedoe');
      final authBloc = await buildBlocWithUser(tester, user);
      addTearDown(authBloc.close);
      final themeCubit = buildThemeCubit(ThemeMode.light);
      addTearDown(themeCubit.close);

      await pumpProfileScreen(tester, authBloc: authBloc, themeCubit: themeCubit);

      // The Logout row sits below the default 800x600 test viewport, so
      // scroll it into view before tapping.
      await tester.ensureVisible(find.widgetWithText(ListTile, StringConstants.kLogout));
      await tester.tap(find.widgetWithText(ListTile, StringConstants.kLogout));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, StringConstants.kLogout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => signOutUsecase(any())).called(1);
    });
  });
}

import 'dart:async';

import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_all_other_devices_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_device_usecase.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/bloc/devices/devices_bloc.dart';
import 'package:fileflow/features/profile/presentation/screens/devices_screen.dart';
import 'package:fileflow/features/profile/presentation/widgets/device_list_item_widget.dart';
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

  late MockWatchDevicesUsecase watchDevicesUsecase;
  late MockLogoutDeviceUsecase logoutDeviceUsecase;
  late MockLogoutAllOtherDevicesUsecase logoutAllOtherDevicesUsecase;

  const deviceOne = DeviceEntity(deviceId: 'device-1', deviceName: 'My Phone', platform: 'android');
  const deviceTwo = DeviceEntity(deviceId: 'device-2', deviceName: 'Other Phone', platform: 'ios');

  setUpAll(registerFallbackValues);

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

    watchDevicesUsecase = MockWatchDevicesUsecase();
    logoutDeviceUsecase = MockLogoutDeviceUsecase();
    logoutAllOtherDevicesUsecase = MockLogoutAllOtherDevicesUsecase();

    when(() => getCurrentDeviceIdUsecase(any())).thenAnswer((_) async => const Right('device-1'));
    when(() => watchCurrentDeviceActiveStatusUsecase(any())).thenAnswer((_) => const Stream<bool>.empty());
    when(() => signOutLocalOnlyUsecase(any())).thenAnswer((_) async => const Right(null));
  });

  tearDown(() async {
    await getIt.reset();
  });

  // Uses `tester.pump(...)` rather than a raw `Future.delayed(...)` to let
  // AuthCheckStatusEvent's async handler chain resolve: under
  // AutomatedTestWidgetsFlutterBinding, Timers (which back Future.delayed)
  // only advance via the test's fake clock, so an un-pumped raw delay never
  // completes and hangs the test indefinitely.
  Future<AuthBloc> buildAuthBlocWithUser(WidgetTester tester, String uid) async {
    when(() => checkAuthStatusUsecase(any())).thenAnswer(
      (_) async => Right(
        AuthStatusResult(isLoggedIn: true, isNewUser: false, uid: uid, user: UserEntity(uid: uid)),
      ),
    );
    final bloc = AuthBloc(
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
    bloc.add(AuthCheckStatusEvent());
    await tester.pump(const Duration(milliseconds: 20));
    return bloc;
  }

  group('DevicesScreen', () {
    testWidgets('shows a loading spinner before the devices list resolves', (tester) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows an empty-state message when there are no devices', (tester) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      controller.add(const []);
      await tester.pump();

      expect(find.text(StringConstants.kNoDevicesFound), findsOneWidget);
    });

    testWidgets('renders one DeviceListItemWidget per device once loaded', (tester) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      controller.add(const [deviceOne, deviceTwo]);
      await tester.pump();

      expect(find.byType(DeviceListItemWidget), findsNWidgets(2));
      expect(find.text(StringConstants.kThisDevice), findsOneWidget);
    });

    testWidgets('tapping a device logout button confirms then dispatches DevicesLogoutOneRequested', (
      tester,
    ) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);
      when(() => logoutDeviceUsecase(any())).thenAnswer((_) async => const Right(null));

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      controller.add(const [deviceOne, deviceTwo]);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kLogOutDevice), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, StringConstants.kLogout));
      await tester.pump();

      verify(
        () => logoutDeviceUsecase(const LogoutDeviceParams(uid: 'uid-1', deviceId: 'device-2')),
      ).called(1);
    });

    testWidgets('"logout all others" confirms then dispatches DevicesLogoutAllOthersRequested', (tester) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);
      when(() => logoutAllOtherDevicesUsecase(any())).thenAnswer((_) async => const Right(null));

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      controller.add(const [deviceOne, deviceTwo]);
      await tester.pump();

      await tester.tap(find.text(StringConstants.kLogOutAllOtherDevicesButton));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kLogOutAllOtherDevicesTitle), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, StringConstants.kLogoutAll));
      await tester.pump();

      verify(
        () => logoutAllOtherDevicesUsecase(
          const LogoutAllOtherDevicesParams(uid: 'uid-1', currentDeviceId: 'device-1'),
        ),
      ).called(1);
    });

    testWidgets('the "logout all others" button is hidden when there are no other devices', (tester) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      // Only the current device — no "other" devices to log out.
      controller.add(const [deviceOne]);
      await tester.pump();

      expect(find.text(StringConstants.kLogOutAllOtherDevicesButton), findsNothing);
    });

    testWidgets('actionInProgressDeviceId shows a spinner only on that device\'s row', (tester) async {
      final controller = StreamController<List<DeviceEntity>>();
      when(() => watchDevicesUsecase(any())).thenAnswer((_) => controller.stream);
      final logoutCompleter = Completer<Either<Failure, void>>();
      when(() => logoutDeviceUsecase(any())).thenAnswer((_) => logoutCompleter.future);

      late DevicesBloc devicesBloc;
      getIt.registerFactory<DevicesBloc>(() {
        devicesBloc = DevicesBloc(
          watchDevicesUsecase,
          getCurrentDeviceIdUsecase,
          logoutDeviceUsecase,
          logoutAllOtherDevicesUsecase,
        );
        return devicesBloc;
      });
      // Not awaited: awaiting these in addTearDown hangs, since teardown runs
      // with no further tester.pump() to drive the fake clock that the
      // StreamController's done-notification needs to resolve.
      addTearDown(() {
        devicesBloc.close();
        controller.close();
      });

      final authBloc = await buildAuthBlocWithUser(tester, 'uid-1');
      addTearDown(authBloc.close);

      await pumpApp(
        tester,
        const DevicesScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
      );

      controller.add(const [deviceOne, deviceTwo]);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, StringConstants.kLogout));
      await tester.pump();

      // The logged-out row now shows a spinner instead of its logout icon,
      // and the current-device row is unaffected (it never has one anyway).
      expect(find.byIcon(Icons.logout), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

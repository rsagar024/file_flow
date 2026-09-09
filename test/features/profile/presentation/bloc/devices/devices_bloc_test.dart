import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_all_other_devices_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_device_usecase.dart';
import 'package:fileflow/features/profile/presentation/bloc/devices/devices_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  late MockWatchDevicesUsecase watchDevicesUsecase;
  late MockGetCurrentDeviceIdUsecase getCurrentDeviceIdUsecase;
  late MockLogoutDeviceUsecase logoutDeviceUsecase;
  late MockLogoutAllOtherDevicesUsecase logoutAllOtherDevicesUsecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    watchDevicesUsecase = MockWatchDevicesUsecase();
    getCurrentDeviceIdUsecase = MockGetCurrentDeviceIdUsecase();
    logoutDeviceUsecase = MockLogoutDeviceUsecase();
    logoutAllOtherDevicesUsecase = MockLogoutAllOtherDevicesUsecase();

    when(
      () => getCurrentDeviceIdUsecase(any()),
    ).thenAnswer((_) async => const Right('device-1'));
  });

  DevicesBloc buildBloc() {
    return DevicesBloc(
      watchDevicesUsecase,
      getCurrentDeviceIdUsecase,
      logoutDeviceUsecase,
      logoutAllOtherDevicesUsecase,
    );
  }

  const deviceOne = DeviceEntity(deviceId: 'device-1', deviceName: 'Phone');
  const deviceTwo = DeviceEntity(deviceId: 'device-2', deviceName: 'Tablet');

  group('DevicesSubscribeRequested', () {
    blocTest<DevicesBloc, DevicesState>(
      'subscribes to the devices stream and emits loaded with devices + '
      'currentDeviceId (derived otherDevices excludes the current device)',
      build: () {
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => Stream.value([deviceOne, deviceTwo]));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const DevicesSubscribeRequested(uid: 'uid-1')),
      wait: const Duration(milliseconds: 20),
      expect: () => [
        const DevicesState(status: DevicesStatus.loading),
        const DevicesState(
          status: DevicesStatus.loading,
          currentDeviceId: 'device-1',
        ),
        const DevicesState(
          status: DevicesStatus.loaded,
          currentDeviceId: 'device-1',
          devices: [deviceOne, deviceTwo],
        ),
      ],
      verify: (bloc) {
        verify(() => getCurrentDeviceIdUsecase(const NoParams())).called(1);
        verify(() => watchDevicesUsecase('uid-1')).called(1);
        expect(bloc.state.otherDevices, [deviceTwo]);
      },
    );

    blocTest<DevicesBloc, DevicesState>(
      'when fetching the current device id fails, emits a failure state for '
      'that step (currentDeviceId lookup), independent of the device stream',
      build: () {
        when(
          () => getCurrentDeviceIdUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('id lookup failed')));
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => Stream.value([deviceOne]));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const DevicesSubscribeRequested(uid: 'uid-1')),
      wait: const Duration(milliseconds: 20),
      expect: () => [
        const DevicesState(status: DevicesStatus.loading),
        const DevicesState(
          status: DevicesStatus.failure,
          errorMessage: 'id lookup failed',
        ),
        const DevicesState(
          status: DevicesStatus.loaded,
          errorMessage: 'id lookup failed',
          devices: [deviceOne],
        ),
      ],
    );

    test(
      'a stream ERROR from watchDevicesUsecase is NOT converted into a '
      'DevicesStatus.failure state — the bloc registers no onError handler '
      'on its .listen(), so the error becomes an uncaught async error '
      'instead of a handled failure state (documents a real bug)',
      () async {
        final controller = StreamController<List<DeviceEntity>>();
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => controller.stream);

        Object? uncaughtError;
        late DevicesBloc bloc;

        // The bloc (and therefore the internal subscription its event
        // handler creates via `.listen()`) must be constructed INSIDE the
        // guarded zone, otherwise the stream error escapes to the outer
        // (root) zone instead of this handler, since Bloc captures the zone
        // active at construction time for its internal event pipeline.
        await runZonedGuarded(
          () async {
            bloc = buildBloc();
            bloc.add(const DevicesSubscribeRequested(uid: 'uid-1'));
            await Future.delayed(const Duration(milliseconds: 20));
            controller.addError(Exception('boom'));
            await Future.delayed(const Duration(milliseconds: 20));
          },
          (error, stack) {
            uncaughtError = error;
          },
        );

        expect(uncaughtError, isNotNull);
        expect(bloc.state.status, isNot(DevicesStatus.failure));

        await bloc.close();
        await controller.close();
      },
    );
  });

  group('DevicesLogoutOneRequested', () {
    blocTest<DevicesBloc, DevicesState>(
      'sets actionInProgressDeviceId during the call and clears it after '
      'success',
      build: () {
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => const Stream<List<DeviceEntity>>.empty());
        when(
          () => logoutDeviceUsecase(any()),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const DevicesSubscribeRequested(uid: 'uid-1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const DevicesLogoutOneRequested(deviceId: 'device-2'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        verify(
          () => logoutDeviceUsecase(
            const LogoutDeviceParams(uid: 'uid-1', deviceId: 'device-2'),
          ),
        ).called(1);
        expect(bloc.state.actionInProgressDeviceId, isNull);
        expect(bloc.state.errorMessage, isNull);
      },
    );

    blocTest<DevicesBloc, DevicesState>(
      'clears actionInProgressDeviceId after a FAILURE too, and records the '
      'error message',
      build: () {
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => const Stream<List<DeviceEntity>>.empty());
        when(
          () => logoutDeviceUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('logout failed')));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const DevicesSubscribeRequested(uid: 'uid-1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const DevicesLogoutOneRequested(deviceId: 'device-2'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.actionInProgressDeviceId, isNull);
        expect(bloc.state.errorMessage, 'logout failed');
      },
    );

    blocTest<DevicesBloc, DevicesState>(
      'does nothing if no subscription (uid) has been established yet',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const DevicesLogoutOneRequested(deviceId: 'device-2')),
      expect: () => <DevicesState>[],
      verify: (_) {
        verifyNever(() => logoutDeviceUsecase(any()));
      },
    );
  });

  group('DevicesLogoutAllOthersRequested', () {
    blocTest<DevicesBloc, DevicesState>(
      'sets isLogoutAllInProgress during the call and clears it after '
      'success',
      build: () {
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => const Stream<List<DeviceEntity>>.empty());
        when(
          () => logoutAllOtherDevicesUsecase(any()),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const DevicesSubscribeRequested(uid: 'uid-1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const DevicesLogoutAllOthersRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        verify(
          () => logoutAllOtherDevicesUsecase(
            const LogoutAllOtherDevicesParams(
              uid: 'uid-1',
              currentDeviceId: 'device-1',
            ),
          ),
        ).called(1);
        expect(bloc.state.isLogoutAllInProgress, isFalse);
        expect(bloc.state.errorMessage, isNull);
      },
    );

    blocTest<DevicesBloc, DevicesState>(
      'clears isLogoutAllInProgress after a FAILURE too, and records the '
      'error message',
      build: () {
        when(
          () => watchDevicesUsecase(any()),
        ).thenAnswer((_) => const Stream<List<DeviceEntity>>.empty());
        when(
          () => logoutAllOtherDevicesUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('logout all failed')));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const DevicesSubscribeRequested(uid: 'uid-1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const DevicesLogoutAllOthersRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.isLogoutAllInProgress, isFalse);
        expect(bloc.state.errorMessage, 'logout all failed');
      },
    );

    blocTest<DevicesBloc, DevicesState>(
      'does nothing if no subscription (uid) has been established yet',
      build: buildBloc,
      act: (bloc) => bloc.add(const DevicesLogoutAllOthersRequested()),
      expect: () => <DevicesState>[],
      verify: (_) {
        verifyNever(() => logoutAllOtherDevicesUsecase(any()));
      },
    );
  });

  group('close()', () {
    test('cancels the devices stream subscription without throwing', () async {
      final controller = StreamController<List<DeviceEntity>>();
      when(
        () => watchDevicesUsecase(any()),
      ).thenAnswer((_) => controller.stream);

      final bloc = buildBloc();
      bloc.add(const DevicesSubscribeRequested(uid: 'uid-1'));
      await Future.delayed(const Duration(milliseconds: 20));

      await bloc.close();

      // Pushing more data after close should not reach a cancelled
      // subscription's callback / crash the test.
      expect(() => controller.add([deviceOne]), returnsNormally);
      await Future.delayed(const Duration(milliseconds: 20));

      await controller.close();
    });
  });
}

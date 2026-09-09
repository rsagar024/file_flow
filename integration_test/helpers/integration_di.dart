import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/services/theme_preferences_service.dart';
import 'package:fileflow/core/themes/cubit/theme_cubit.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/bloc/devices/devices_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../test/helpers/mocks.dart';

/// The mocked auth usecases backing the `AuthBloc` registered into [getIt] by
/// [setUpIntegrationDi], in the exact constructor order `AuthBloc` expects
/// (mirrors `injection_container.dart`'s `_registerBlocs`).
class MockedAuthUsecases {
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
}

/// The mocked device usecases backing the `DevicesBloc` registered into
/// [getIt] by [setUpIntegrationDi] (its own `GetCurrentDeviceIdUsecase`
/// instance, separate from [MockedAuthUsecases.getCurrentDeviceIdUsecase],
/// matching `injection_container.dart` where both blocs are handed their own
/// `getIt<GetCurrentDeviceIdUsecase>()` resolution).
class MockedDeviceUsecases {
  final watchDevicesUsecase = MockWatchDevicesUsecase();
  final getCurrentDeviceIdUsecase = MockGetCurrentDeviceIdUsecase();
  final logoutDeviceUsecase = MockLogoutDeviceUsecase();
  final logoutAllOtherDevicesUsecase = MockLogoutAllOtherDevicesUsecase();
}

class IntegrationDi {
  const IntegrationDi(this.auth, this.devices, this.themePreferencesService);

  final MockedAuthUsecases auth;
  final MockedDeviceUsecases devices;
  final MockThemePreferencesService themePreferencesService;
}

/// Populates the real [getIt] singleton with a mocked stand-in for
/// `initDependencies()`'s `_registerCoreService` (`ThemePreferencesService`
/// only — no journey reads `DeviceInfoService`/`ImagePickerService`) and
/// `_registerBlocs`, skipping `_registerFirebase`/`_registerDataSources`/
/// `_registerRepositories`/`_registerUseCase` entirely by constructing
/// `AuthBloc`/`DevicesBloc` directly from mocked usecases. This must never
/// call `initDependencies()` itself — that touches real
/// `FirebaseAuth.instance`/`FirebaseFirestore.instance`, which aren't
/// available under `flutter test`.
///
/// Registers baseline happy-path stubs for the usecases `AuthBloc` calls
/// unconditionally on every successful auth transition
/// (`getCurrentDeviceIdUsecase`, `watchCurrentDeviceActiveStatusUsecase`,
/// `signOutLocalOnlyUsecase`) so individual journeys only need to stub what's
/// specific to them. Callers MUST `addTearDown(tearDownIntegrationDi)`
/// immediately after calling this, since [getIt] is a real global singleton.
IntegrationDi setUpIntegrationDi() {
  final auth = MockedAuthUsecases();
  final devices = MockedDeviceUsecases();
  final themePreferencesService = MockThemePreferencesService();

  when(() => auth.getCurrentDeviceIdUsecase(any())).thenAnswer((_) async => const Right('device-1'));
  when(() => auth.watchCurrentDeviceActiveStatusUsecase(any())).thenAnswer((_) => const Stream<bool>.empty());
  when(() => auth.signOutLocalOnlyUsecase(any())).thenAnswer((_) async => const Right(null));
  when(() => themePreferencesService.readThemeMode()).thenAnswer((_) async => null);
  when(() => themePreferencesService.writeThemeMode(any())).thenAnswer((_) async {});

  getIt
    ..registerLazySingleton<ThemePreferencesService>(() => themePreferencesService)
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        auth.sendOtpUsecase,
        auth.verifyOtpUsecase,
        auth.resendOtpUsecase,
        auth.checkAuthStatusUsecase,
        auth.createAccountUsecase,
        auth.signOutUsecase,
        auth.getCurrentDeviceIdUsecase,
        auth.watchCurrentDeviceActiveStatusUsecase,
        auth.signOutLocalOnlyUsecase,
        auth.updateProfileUsecase,
      ),
    )
    ..registerFactory<DevicesBloc>(
      () => DevicesBloc(
        devices.watchDevicesUsecase,
        devices.getCurrentDeviceIdUsecase,
        devices.logoutDeviceUsecase,
        devices.logoutAllOtherDevicesUsecase,
      ),
    )
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(themePreferencesService));

  return IntegrationDi(auth, devices, themePreferencesService);
}

/// Resets the real [getIt] singleton so no lazy singleton (and its internal
/// `StreamSubscription`s/`Timer`s, e.g. `AuthBloc`'s) leaks into the next
/// test. Always call via `addTearDown` right after [setUpIntegrationDi].
Future<void> tearDownIntegrationDi() => getIt.reset();

# Design & Architecture

This document describes how FileFlow is built today, using the `auth` feature as the worked example (it's the only feature with a complete implementation). Conventions here are meant to be followed when other features (home, upload) get wired up for real.

## Layered architecture

Each feature under `lib/features/<name>/` is split into three layers:

```
presentation/   screens, widgets, bloc (event/state/bloc)
      ↓ calls
domain/         entities, repository interfaces, usecases
      ↑ implements
data/           models, datasources (Firebase calls), repository implementations
```

Dependencies point inward: `presentation` depends on `domain`, `data` depends on `domain`, but `domain` depends on nothing feature-specific. Only `auth` currently has all three layers; `home`, `upload`, `dashboard`, `splash` are `presentation`-only stubs, and `profile` has its own `presentation` layer but reuses `auth`'s `domain`/`data` layers for device management (see below).

### Worked example: `auth`

- **Entities** (`domain/entities/`): `UserEntity` (profile fields, `storageUsedBytes`/`storageLimitBytes`/`totalFilesCount`, `devices: Map<String, DeviceEntity>?`, `isNewUser`), `DeviceEntity` (`deviceId`, `deviceName`, `deviceModel`, `platform`, `appVersion`, `fcmToken`, `isActive`, `lastLoginAt`). Both are `Equatable` and expose `toModel()` to convert to their `data/models` counterpart.
- **Repository interface** (`domain/repositories/auth_repository.dart`): `sendOtp`, `verifyOtp`, `resendOtp`, `checkAuthState`, `createAccount`, `signOut`, `signInWithAutoVerifiedCredential`, `watchDevices` (stream), `watchCurrentDeviceActiveStatus` (stream), `getCurrentDeviceId`, `logoutDevice`, `logoutAllOtherDevices`, `signOutLocalOnly`. Also defines `AuthResult` and `AuthStatusResult` value objects returned by some methods.
- **Usecases** (`domain/usecases/`): one class per repository method (`SendOtpUsecase`, `VerifyOtpUsecase`, `ResendOtpUsecase`, `CheckAuthStatusUsecase`, `CreateAccountUsecase`, `SignOutUsecase`, `SignOutLocalOnlyUsecase`, `GetCurrentDeviceIdUsecase`, `WatchDevicesUsecase`, `WatchCurrentDeviceActiveStatusUsecase`, `LogoutDeviceUsecase`, `LogoutAllOtherDevicesUsecase`), each just delegating to the repository — this indirection is what lets blocs depend on `domain` only.
- **Datasource** (`data/datasources/auth_remote_datasource_impl.dart`): talks directly to `FirebaseAuth` and `FirebaseFirestore`. Handles OTP verification codes/resend tokens, reads/writes the Firestore `users/{uid}` document, and includes migration logic that converts a legacy "devices as list" document shape into the current "devices as map" shape the first time it encounters one.
- **Repository impl** (`data/repositories/auth_repository_impl.dart`): implements `AuthRepository`, converts datasource exceptions into `Failure`, wraps results in `Either`.
- **Bloc** (`presentation/bloc/auth_bloc.dart` + `auth_event.dart` + `auth_state.dart`): app-wide, provided once in `main.dart` via `MultiBlocProvider`. Drives navigation redirects elsewhere in the app by exposing an `AuthAppStatus` on its state (e.g. `DashboardScreen` listens for `unAuthenticated` and calls `context.go(LoginScreen.routeName)`).

### `profile` feature

`profile/presentation/bloc/devices/devices_bloc.dart` has its own bloc but no separate `domain`/`data` layer — it's constructed with `auth`'s usecases (`GetCurrentDeviceIdUsecase`, `WatchDevicesUsecase`, `LogoutDeviceUsecase`, `LogoutAllOtherDevicesUsecase` — see the DI graph below), since device data lives on the same Firestore user document that `auth` owns.

## Dependency injection graph

Wired in `lib/core/di/injection_container.dart`, called once from `main()` as `initDependencies()`, in this fixed order:

1. **`_registerFirebase`** — `FirebaseAuth.instance`, `FirebaseFirestore.instance` (lazy singletons)
2. **`_registerCoreService`** — `DeviceInfoService`, `ImagePickerService` (lazy singletons)
3. **`_registerDataSources`** — `AuthRemoteDatasource` (lazy singleton, depends on Firebase instances)
4. **`_registerRepositories`** — `AuthRepository` (lazy singleton, depends on the datasource + a core service)
5. **`_registerUseCase`** — all 12 auth usecases (lazy singletons, each depends on `AuthRepository`)
6. **`_registerBlocs`** — `AuthBloc` (lazy singleton, depends on 9 usecases) and `DevicesBloc` (**factory** — a new instance per screen, depends on 4 device-related usecases)

Later stages depend only on earlier ones — when wiring a new feature, follow the same order and extend the matching `_register*` function rather than inventing a new registration point.

## Firestore data model

Single collection, one document per user:

```
users/{uid}
  email, displayName, username, photoUrl, phoneNumber
  storageUsedBytes, storageLimitBytes   # default limit: 5 GiB (5368709120 bytes) on account creation
  totalFilesCount
  createdAt, updatedAt
  devices: {
    "<deviceId>": {
      deviceName, deviceModel, platform, appVersion, fcmToken,
      isActive, lastLoginAt
    },
    ...
  }
```

`devices` is a map keyed by device id (not a list) so a device's active/inactive status can be updated in place without rewriting the whole array. Older documents may still have `devices` as a list from before this shape existed — `AuthRemoteDatasourceImpl` detects and migrates that shape to the map form on read.

## Error handling

Usecases and repositories return `Future<Either<Failure, T>>` (`fpdart`) rather than throwing. `Failure` (`lib/core/error/failure.dart`) is intentionally minimal — just a `message` string, no error codes/types yet. Streams (`watchDevices`, `watchCurrentDeviceActiveStatus`) are plain `Stream<T>`, not wrapped in `Either`, since bloc listeners handle stream errors directly.

## UI conventions

- **Base widgets** (`lib/core/common/base/presentation/`): `FileFlowStatefulWidget` / `FileFlowStatelessWidget`, plus `Background*` variants that layer in the app's custom painted background. Override `buildContent(context)` and `onInit()`/`onDispose()` instead of Flutter's normal `build`/`initState`/`dispose`.
- **Shared widgets** (`lib/core/common/widgets/`): app bar, button, text field, OTP pin field, phone field (with bundled country data), confirmation dialog, selectable-item bottom sheet, folder card.
- **Custom painters** (`lib/core/common/shapes/`): background painter, dotted-border painter (used for the upload drop zone), sharp-divider painter.
- **Theming** (`lib/core/themes/`): `AppColors` (named palette), `text_styles.dart`. `main.dart` builds the `MaterialApp` theme via `ColorScheme.fromSeed(seedColor: AppColors.primary)` and forces `TextScaler.linear(1)` app-wide (disables device font-scaling accessibility setting — intentional design choice, not an oversight).

## Explicitly not designed yet

- File storage/sync backend (no `firebase_storage` dependency, no upload pipeline)
- Sharing feature (dashboard tab is a placeholder `Text` widget)
- Settings feature (dashboard tab is a placeholder, non-functional)
- Any data layer for `home`/`upload`/`dashboard` — their current code is presentation-only and shouldn't be treated as a pattern to copy for a real data-backed feature; use `auth` for that instead.

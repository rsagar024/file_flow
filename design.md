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
- **Repository interface** (`domain/repositories/auth_repository.dart`): `sendOtp`, `verifyOtp`, `resendOtp`, `checkAuthState`, `createAccount`, `updateProfile`, `signOut`, `signInWithAutoVerifiedCredential`, `watchDevices` (stream), `watchCurrentDeviceActiveStatus` (stream), `getCurrentDeviceId`, `logoutDevice`, `logoutAllOtherDevices`, `signOutLocalOnly`. Also defines `AuthResult` and `AuthStatusResult` value objects returned by some methods.
- **Usecases** (`domain/usecases/`): one class per repository method — 13 in total, each just delegating to the repository (`SendOtpUsecase`, `VerifyOtpUsecase`, `ResendOtpUsecase`, `CheckAuthStatusUsecase`, `CreateAccountUsecase`, `UpdateProfileUsecase`, `SignOutUsecase`, `SignOutLocalOnlyUsecase`, `GetCurrentDeviceIdUsecase`, `WatchDevicesUsecase`, `WatchCurrentDeviceActiveStatusUsecase`, `LogoutDeviceUsecase`, `LogoutAllOtherDevicesUsecase`) — this indirection is what lets blocs depend on `domain` only.
- **Datasource** (`data/datasources/auth_remote_datasource_impl.dart`): talks directly to `FirebaseAuth` and `FirebaseFirestore`. Handles OTP verification codes/resend tokens, reads/writes the Firestore `users/{uid}` document, and includes migration logic that converts a legacy "devices as list" document shape into the current "devices as map" shape the first time it encounters one.
- **Repository impl** (`data/repositories/auth_repository_impl.dart`): implements `AuthRepository`, converts datasource exceptions into `Failure`, wraps results in `Either`.
- **Bloc** (`presentation/bloc/auth_bloc.dart` + `auth_event.dart` + `auth_state.dart`): app-wide, provided once in `main.dart` via `MultiBlocProvider`. Drives navigation redirects elsewhere in the app by exposing an `AuthAppStatus` on its state (e.g. `DashboardScreen` listens for `unAuthenticated` and calls `context.go(LoginScreen.routeName)`).

### `profile` feature

`profile/presentation/bloc/devices/devices_bloc.dart` has its own bloc but no separate `domain`/`data` layer — it's constructed with `auth`'s usecases (`GetCurrentDeviceIdUsecase`, `WatchDevicesUsecase`, `LogoutDeviceUsecase`, `LogoutAllOtherDevicesUsecase` — see the DI graph below), since device data lives on the same Firestore user document that `auth` owns.

## Dependency injection graph

Wired in `lib/core/di/injection_container.dart`, called once from `main()` as `initDependencies()`, in this fixed order:

1. **`_registerFirebase`** — `FirebaseAuth.instance`, `FirebaseFirestore.instance` (lazy singletons)
2. **`_registerCoreService`** — `DeviceInfoService`, `ImagePickerService`, `ThemePreferencesService` (lazy singletons)
3. **`_registerDataSources`** — `AuthRemoteDatasource` (lazy singleton, depends on Firebase instances)
4. **`_registerRepositories`** — `AuthRepository` (lazy singleton, depends on the datasource + a core service)
5. **`_registerUseCase`** — all 13 auth usecases (lazy singletons, each depends on `AuthRepository`)
6. **`_registerBlocs`** — `AuthBloc` (lazy singleton, depends on 10 usecases), `DevicesBloc` (**factory** — a new instance per screen, depends on 4 device-related usecases), and `ThemeCubit` (lazy singleton, depends on `ThemePreferencesService`)

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
- **Shared widgets** (`lib/core/common/widgets/`): app bar, button, text field, OTP pin field, phone field (with bundled country data), confirmation dialog, selectable-item bottom sheet, folder card, `UserAvatar` (network image / local file / initials-or-icon fallback), `ThemeModeSelector` (segmented system/light/dark control).
- **Custom painters** (`lib/core/common/shapes/`): background painter, dotted-border painter (used for the upload drop zone), sharp-divider painter.
- **Theming** (`lib/core/themes/`): `AppColors` is the named palette; `SemanticColors` (`semantic_colors.dart`) is a `ThemeExtension` with `.light`/`.dark` instances (background, surface, surfaceVariant, text tones, active/inactive/pressed/disabled) that widgets read via the `context.colors` getter (`lib/core/extensions/build_context_theme_extension.dart`) instead of touching `AppColors` directly. `ThemeCubit`/`ThemeState` (`themes/cubit/`) hold the current `ThemeMode`, persisted through `ThemePreferencesService` (`flutter_secure_storage`); `main.dart` wraps the app in a `BlocBuilder<ThemeCubit, ThemeState>` and builds both `theme`/`darkTheme` (each carrying the matching `SemanticColors` extension via `ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: ...)`) with `themeMode: themeState.mode`. Switching between light and dark (not just toggling `system`) plays a circular-reveal animation via `ThemeRevealController`, which snapshots the current UI (from a `RepaintBoundary` keyed in `main.dart`) and animates an expanding circular clip from the tap origin over the new theme. Font scaling is separately forced to `TextScaler.linear(1)` app-wide (disables the device accessibility setting — intentional, not an oversight).

## Explicitly not designed yet

- File storage/sync backend (no `firebase_storage` dependency, no upload pipeline)
- Sharing feature (dashboard tab is a placeholder `Text` widget)
- Settings feature (dashboard tab is a placeholder, non-functional)
- Any data layer for `home`/`upload`/`dashboard` — their current code is presentation-only and shouldn't be treated as a pattern to copy for a real data-backed feature; use `auth` for that instead.

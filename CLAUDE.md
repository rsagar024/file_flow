# CLAUDE.md

Guidance for Claude Code sessions working in this repository.

## Project

FileFlow is a Flutter app for secure file storage/sync across devices, with Firebase Auth (phone/OTP) and Firestore as the backend. See [`README.md`](README.md#current-status) for what's actually implemented vs UI scaffolding — don't assume a feature works just because a screen exists for it.

## Architecture rules

- **Clean architecture per feature**: `lib/features/<name>/{data,domain,presentation}`. Only `auth` has all three layers fully built — treat it as the reference implementation when building out another feature (e.g. home/upload) for real.
  - `domain/entities` — plain `Equatable` value objects
  - `domain/repositories` — abstract interfaces
  - `domain/usecases` — one class per operation, callable (`call(...)`), returns `Future<Either<Failure, T>>` (or a `Stream<T>` for `StreamUseCase`) — base classes in `lib/core/usecase/usecase.dart`
  - `data/models` — `toJson`/`fromJson` + `toEntity()`/`toModel()` conversions
  - `data/datasources` — talk directly to Firebase (`firebase_auth`, `cloud_firestore`)
  - `data/repositories` — implement the domain interface, wrap datasource calls in `Either`
- **State management**: `flutter_bloc`. Each bloc is split into three files via `part`/`part of`: `<name>_bloc.dart`, `<name>_event.dart`, `<name>_state.dart` (see `features/auth/presentation/bloc/` and `features/profile/presentation/bloc/devices/`). App-level, non-feature state (e.g. `ThemeCubit` in `lib/core/themes/cubit/`) uses a plain `Cubit` instead of the 3-file bloc split.
- **DI**: `get_it`, wired in `lib/core/di/injection_container.dart` via `initDependencies()`, in this order: `_registerFirebase` → `_registerCoreService` → `_registerDataSources` → `_registerRepositories` → `_registerUseCase` → `_registerBlocs`. Most bindings are `registerLazySingleton`; blocs that are recreated per screen (e.g. `DevicesBloc`) use `registerFactory`. Add new dependencies to the matching `_register*` function, keeping the same ordering.
- **Error handling**: usecases/repositories return `Either<Failure, Success>` (`fpdart`). `Failure` (`lib/core/error/failure.dart`) is just `{ message }`. Don't let exceptions cross from `data` into `domain`/`presentation` — catch and convert to `Failure` at the datasource/repository boundary.
- **Routing**: flat `go_router` table in `lib/core/routes/app_route.dart`. Each screen exposes a `static const routeName`. There are no nested/shell routes — `DashboardScreen` implements its own bottom-nav tab switching internally via `PageView`, not via router nesting.

## Conventions to follow

- Use `FileFlowStatefulWidget` / `FileFlowStatelessWidget` (and their `Background*` variants) from `lib/core/common/base/presentation/` instead of raw `StatefulWidget`/`StatelessWidget`. Override `buildContent(context)` (not `build`), and `onInit()`/`onDispose()` for lifecycle instead of `initState`/`dispose`.
- No hardcoded UI strings — add them to `lib/core/resources/common/string_constants.dart` (`StringConstants.k...`) and reference from there.
- No raw `Color(...)` literals — use `AppColors` (`lib/core/themes/app_colors.dart`) and the text styles in `lib/core/themes/text_styles.dart`. For anything that should adapt between light/dark mode, prefer the semantic tokens on `context.colors` (`lib/core/extensions/build_context_theme_extension.dart`, backed by `SemanticColors` in `lib/core/themes/semantic_colors.dart`) over `AppColors` directly.
- Reuse existing shared widgets in `lib/core/common/widgets/` (app bar, buttons, text fields, OTP pin field, phone field with country picker, confirmation dialog, bottom sheets) rather than rebuilding similar UI inline.

## Known gaps — don't assume these are done

- Home, Upload, Folder Details screens, and the Sharing/Settings dashboard tabs are UI-only stubs with no data wiring. Profile is not one of these — it has real update functionality (`UpdateProfileUsecase`) and full light/dark/system theming; don't treat it as a stub.
- No `firebase_storage` dependency exists yet — actual file upload/storage is unbuilt.
- `test/widget_test.dart` is stale Flutter counter-app boilerplate and doesn't match the app; there is no real test coverage yet.
- No CI gate runs `flutter analyze`/`flutter test` on PRs — the GitHub workflows only build and publish releases after merge (see `.github/workflows/`).

## Before committing

Run `flutter analyze` yourself before committing — nothing else will catch lint/type errors until a human reviews the PR. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for branch/commit conventions.

## Further reading

- [`design.md`](design.md) — architecture, DI graph, and Firestore data model in depth
- [`flow.md`](flow.md) — screen and navigation flow

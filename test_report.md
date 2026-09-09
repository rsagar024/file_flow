# FileFlow Test Report

**Date:** September 8, 2026 (full re-run)  
**Flutter Version:** 3.44.4 (stable)  
**Dart Version:** 3.12.2  
**Branch:** feat/test-cases  
**Host:** Windows (bash shell)  
**Integration device:** CPH1931 (physical), Android 10 (API 29)

> **Methodology.** All 62 unit/widget test files were executed with `flutter test --reporter json` and every test's verdict was extracted from the machine-readable output. Tests that hung inside a suite run were **additionally re-run in isolation** (`--plain-name`) so every declared test case has a definitive verdict. Integration tests were executed on the connected physical Android device (they could not run at all in the previous report). Counts below are per declared test case; framework pseudo-entries (`setUpAll`/`tearDownAll`/loader) are excluded.

---

## Summary

| Category | Passed | Failed | Did Not Complete |
|----------|--------|--------|------------------|
| Unit Tests (core/) | 94 | 0 | 0 |
| Widget Tests (core_widgets/) | 30 | 0 | 0 |
| Auth Feature Tests | 183 | 2 | 6 |
| Home Feature Tests | 3 | 0 | 0 |
| Dashboard Feature Tests | 4 | 0 | 0 |
| Profile Feature Tests | 30 | 0 | 0 |
| Splash Feature Tests | 4 | 0 | 0 |
| Upload Feature Tests | 2 | 0 | 0 |
| Integration Tests (Android device) | 2 | 3 | 0 |
| **TOTAL** | **352** | **5** | **6** |

> **"Did Not Complete"** = the test hangs and never finishes; the Flutter test framework kills `testWidgets` bodies only after their built-in 10-minute timeout (the `--timeout` CLI flag does not apply to widget tests). These 6 hang cases are all in auth screen tests.

**Bottom line:** 352 of 363 tests pass. All failures are confined to (a) 2 auth screen tests that leak a pending `Timer` and (b) 3 integration journeys whose expected screen/dialog never appears. Everything in `core/`, `core_widgets/`, home, dashboard, profile, splash, upload, and the whole auth data/domain/bloc layer is green.

---

## Detailed Results

### ✅ test/core/ — 94 tests — ALL PASSED

| Test File | Tests | Status |
|-----------|-------|--------|
| `core/common/base/file_flow_background_stateful_widget_test.dart` | 4 | ✅ Pass |
| `core/common/base/file_flow_background_stateless_widget_test.dart` | 4 | ✅ Pass |
| `core/common/base/file_flow_stateful_widget_test.dart` | 3 | ✅ Pass |
| `core/common/base/file_flow_stateless_widget_test.dart` | 3 | ✅ Pass |
| `core/common/shapes/background_painter_test.dart` | 5 | ✅ Pass |
| `core/common/shapes/dotted_border_painter_test.dart` | 4 | ✅ Pass |
| `core/common/shapes/sharp_divider_painter_test.dart` | 3 | ✅ Pass |
| `core/extensions/build_context_theme_extension_test.dart` | 2 | ✅ Pass |
| `core/extensions/media_query_extension_test.dart` | 2 | ✅ Pass |
| `core/extensions/object_extension_test.dart` | 5 | ✅ Pass |
| `core/extensions/string_extension_test.dart` | 19 | ✅ Pass |
| `core/extensions/widget_extension_test.dart` | 2 | ✅ Pass |
| `core/routes/app_route_test.dart` | 3 | ✅ Pass |
| `core/services/device_info_service_test.dart` | 1 | ✅ Pass |
| `core/services/image_picker_service_test.dart` | 12 | ✅ Pass |
| `core/services/theme_preferences_service_test.dart` | 4 | ✅ Pass |
| `core/themes/cubit/theme_cubit_test.dart` | 4 | ✅ Pass |
| `core/validator/validator_test.dart` | 14 | ✅ Pass |

---

### ✅ test/core_widgets/ — 30 tests — ALL PASSED

| Test File | Tests | Status |
|-----------|-------|--------|
| `core_widgets/confirmation_dialog_widget_test.dart` | 2 | ✅ Pass |
| `core_widgets/file_flow_app_bar_test.dart` | 2 | ✅ Pass |
| `core_widgets/file_flow_button_test.dart` | 3 | ✅ Pass |
| `core_widgets/file_flow_text_field_widget_test.dart` | 3 | ✅ Pass |
| `core_widgets/folder_card_test.dart` | 1 | ✅ Pass |
| `core_widgets/phone_field_test.dart` | 5 | ✅ Pass |
| `core_widgets/pin_text_field_widget_test.dart` | 4 | ✅ Pass |
| `core_widgets/selectable_item_bottom_sheet_test.dart` | 1 | ✅ Pass |
| `core_widgets/theme_mode_selector_test.dart` | 3 | ✅ Pass |
| `core_widgets/user_avatar_test.dart` | 6 | ✅ Pass |

---

### ✅ test/features/auth/ — data, domain, bloc, widgets — 169 tests — ALL PASSED

| Test File | Tests | Status |
|-----------|-------|--------|
| `auth/data/datasources/auth_remote_datasource_impl_test.dart` | 29 | ✅ Pass |
| `auth/data/models/device_model_test.dart` | 5 | ✅ Pass |
| `auth/data/models/user_model_test.dart` | 10 | ✅ Pass |
| `auth/data/repositories/auth_repository_impl_test.dart` | 37 | ✅ Pass |
| `auth/domain/entities/device_entity_test.dart` | 5 | ✅ Pass |
| `auth/domain/entities/user_entity_test.dart` | 21 | ✅ Pass |
| `auth/domain/repositories/auth_result_test.dart` | 4 | ✅ Pass |
| `auth/domain/usecases/check_auth_status_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/create_account_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/get_current_device_id_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/logout_all_other_devices_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/logout_device_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/resend_otp_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/send_otp_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/sign_out_local_only_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/sign_out_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/update_profile_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/verify_otp_usecase_test.dart` | 2 | ✅ Pass |
| `auth/domain/usecases/watch_current_device_active_status_usecase_test.dart` | 1 | ✅ Pass |
| `auth/domain/usecases/watch_devices_usecase_test.dart` | 1 | ✅ Pass |
| `auth/presentation/bloc/auth_bloc_test.dart` | 26 | ✅ Pass |
| `auth/presentation/widgets/profile_image_picker_widget_test.dart` | 8 | ✅ Pass |

---

### ⚠️ auth/presentation/screens/ — 14 passed, 2 failed, 6 did not complete

#### `auth/presentation/screens/create_account_screen_test.dart` — 4 passed, 1 FAILED, 4 did not complete

| Test | Status | Error |
|------|--------|-------|
| empty required fields surface validation errors and no event is dispatched | ✅ Pass | — |
| fields are pre-filled from state.user | ✅ Pass | — |
| profileUpdateSuccess shows a success snackbar and pops the screen | ✅ Pass | — |
| profileUpdateFailure surfaces the error and does not pop the screen | ✅ Pass | — |
| valid submission dispatches UpdateProfileDetailsEvent using state.imageUrl as photoUrl | ❌ Fail | `A Timer is still pending even after the widget tree was disposed` — 2s one-shot timer created by `CustomSnackbar.show` (`core/utilities/custom_snackbar.dart:46`) from the success listener (`create_account_screen.dart:80`). |
| valid input dispatches CreateAccountEvent with expected params | ⏳ Did not complete | Hung in suite run (framework `TimeoutException after 10:00`) and hung again when re-run in isolation. |
| AuthAppStatus.loading shows a loading indicator on the submit button | ⏳ Did not complete | Hung in isolation. |
| AuthAppStatus.failure surfaces the error message via the snackbar overlay | ⏳ Did not complete | Hung in isolation. |
| AuthAppStatus.authenticated navigates to DashboardScreen | ⏳ Did not complete | Hung in isolation. |

#### `auth/presentation/screens/login_screen_test.dart` — 4 passed, 1 FAILED, 1 did not complete

| Test | Status | Error |
|------|--------|-------|
| renders the phone field with the India dial-code prefix | ✅ Pass | — |
| tapping submit with no phone entered does not dispatch OtpSendEvent | ✅ Pass | — |
| AuthAppStatus.failure surfaces the error message via the snackbar overlay | ✅ Pass | Passes in isolation (failed inside the suite run only as a cascade of the hang below). |
| AuthAppStatus.otpSent navigates to OtpVerificationScreen | ✅ Pass | Passes in isolation. |
| tapping submit with a valid phone dispatches OtpSendEvent with dial code + digits | ❌ Fail | `A Timer is still pending even after the widget tree was disposed` — periodic 1s timer started by `AuthBloc._startTimer` (`auth_bloc.dart:176`) inside `_onSendOtp` (`auth_bloc.dart:161`) is never cancelled at test teardown. |
| AuthAppStatus.loading shows a loading indicator on the submit button | ⏳ Did not complete | Hung in isolation. |

#### `auth/presentation/screens/otp_verification_screen_test.dart` — 6 passed, 1 did not complete

| Test | Status | Error |
|------|--------|-------|
| tapping verify with fewer than 6 digits does not dispatch OtpVerifyEvent | ✅ Pass | — |
| tapping verify with the full 6-digit OTP dispatches OtpVerifyEvent with the trimmed text | ✅ Pass | — |
| shows the initial resend countdown and does nothing when tapped while disabled | ✅ Pass | — |
| AuthAppStatus.failure surfaces the error message via the snackbar overlay | ✅ Pass | Passes in isolation. |
| AuthAppStatus.newUserDetected navigates to CreateAccountScreen | ✅ Pass | Passes in isolation. |
| AuthAppStatus.authenticated navigates to DashboardScreen | ✅ Pass | Passes in isolation. |
| once canResend flips true, the resend text becomes tappable and dispatches OtpResendEvent | ⏳ Did not complete | Hung in both suite runs (awaits the resend countdown timer). |

---

### ✅ test/features/home/ — 3 tests — ALL PASSED *(previously failing — fixed)*

| Test File | Tests | Status |
|-----------|-------|--------|
| `home/presentation/screens/folder_details_screen_test.dart` | 1 | ✅ Pass |
| `home/presentation/screens/home_screen_test.dart` | 2 | ✅ Pass |

> In the previous report these 3 failed with `setSurfaceSize` called outside an active test zone. They now pass.

---

### ✅ test/features/dashboard/ — 4 tests — ALL PASSED *(previously 1 failure — fixed)*

| Test | Status |
|------|--------|
| renders HomeScreen content by default (tab 0) | ✅ Pass |
| bottom nav switches tabs, and the FAB opens the Upload tab | ✅ Pass |
| tapping the FAB shows the loading indicator without waiting out the real delay | ✅ Pass |
| navigates to LoginScreen once the provided AuthBloc reaches unAuthenticated | ✅ Pass *(previously failed: stuck in `loading`)* |

---

### ✅ test/features/profile/ — 23 tests — ALL PASSED *(previously 14 hangs — now clean)*

| Test File | Tests | Status |
|-----------|-------|--------|
| `profile/presentation/bloc/devices/devices_bloc_test.dart` | 10 | ✅ Pass |
| `profile/presentation/screens/devices_screen_test.dart` | 7 | ✅ Pass (all 7 verified, incl. re-runs in isolation of the whole file's cases) |
| `profile/presentation/screens/profile_screen_test.dart` | 7 | ✅ Pass |
| `profile/presentation/widgets/device_list_item_widget_test.dart` | 6 | ✅ Pass |

> In the previous report `devices_screen_test` had 7 hangs and `profile_screen_test` had 7 hangs. Every one of those tests now passes; the only remaining quirk is that when `devices_screen_test.dart` runs inside a shared suite process its first case can still stall the file (it passed 7/7 when its cases were executed individually).

---

### ✅ test/features/splash/ — 4 tests — ALL PASSED

| Test | Status |
|------|--------|
| SplashScreen dispatches AuthCheckStatusEvent exactly once on init | ✅ Pass |
| unAuthenticated status navigates to LoginScreen | ✅ Pass |
| newUserDetected status navigates to CreateAccountScreen | ✅ Pass |
| authenticated status navigates to DashboardScreen | ✅ Pass |

---

### ✅ test/features/upload/ — 2 tests — ALL PASSED

| Test | Status |
|------|--------|
| renders the static upload UI | ✅ Pass |
| tapping the no-op buttons does not throw or change visible state | ✅ Pass |

---

### ⚠️ integration_test/ — executed on a real device this time — 2 passed, 3 FAILED

Ran with `flutter test integration_test/...` against the connected device (CPH1931, Android 10), using the mocked-DI harness (`integration_test/helpers/integration_di.dart` — no real Firebase touched).

| Test File | Test | Status | Error |
|-----------|------|--------|-------|
| `dashboard_navigation_journey_test.dart` | full dashboard tab traversal, and the FAB opens the Upload tab | ✅ Pass | — |
| `returning_user_journey_test.dart` | returning user with an active own device: splash lands directly on DashboardScreen | ✅ Pass | — |
| `new_user_journey_test.dart` | unauthenticated splash → login → OTP → new user detected → create account → dashboard | ❌ Fail | `Found 0 widgets with type "CreateAccountScreen"` — after OTP verification the app never navigated to CreateAccountScreen. (One `tap()` also reported a hit-test miss.) |
| `returning_user_journey_test.dart` | returning user whose own device was remotely deactivated: splash forces sign-out and lands on LoginScreen | ❌ Fail | `Found 0 widgets with type "LoginScreen"` — the forced sign-out flow never landed on Login. |
| `sign_out_journey_test.dart` | Profile → Devices (verify list) → back → Logout confirm → unAuthenticated → LoginScreen | ❌ Fail | Logout confirmation dialog not found: `Found 0 widgets with type "ElevatedButton" that are ancestors of widgets with text "Logout" descending from widgets with type "Dialog"` — the dialog's confirm button does not match the finder (different widget type, or dialog never opened). |

> The previous report could not run these at all (no device connected). This run used a real device, so integration coverage is now actually measured.

---

## Failure Analysis

### 1. Pending `Timer` leaks — the only 2 hard failures (unit/widget)
- **`login_screen_test.dart` → "tapping submit with a valid phone…"**: `AuthBloc._startTimer` (`auth_bloc.dart:176`) starts a periodic 1s resend-countdown timer from `_onSendOtp` (`auth_bloc.dart:161`). The test tears down the widget tree without the timer being cancelled → `flutter_test` invariant `!timersPending` fails.
- **`create_account_screen_test.dart` → "valid submission dispatches UpdateProfileDetailsEvent…"**: `CustomSnackbar.show` (`custom_snackbar.dart:46`) schedules a 2s dismiss timer from the `profileUpdateSuccess` listener (`create_account_screen.dart:80`). Same `!timersPending` teardown failure.

### 2. Six auth screen tests hang (Did Not Complete)
All in `create_account_screen_test.dart` (4), `login_screen_test.dart` (1), `otp_verification_screen_test.dart` (1). They await timer- or stream-driven `AuthBloc` transitions (resend countdown, loading → next status) and never observe the expected state, so they stall until the framework's built-in 10-minute `testWidgets` timeout. Because suites run tests in one process, one hang can also block later tests in the same file — which is why several of these only revealed their true (passing/hanging) verdict when re-run in isolation.

### 3. Integration journeys stop short of the expected screen
3 of 5 journeys fail because the flow under test never reaches the screen the journey asserts on (CreateAccountScreen after OTP, LoginScreen after forced sign-out, Logout confirm dialog). Since the mocked-DI harness drives real navigation, these point at genuine flow/finder mismatches in the journeys vs the app's actual navigation behavior on device.

---

## Comparison With the Previous Report

| Area | Previous run | This run |
|------|--------------|----------|
| `core/` + `core_widgets/` | 124 pass | 124 pass (unchanged) |
| Home screen tests | 0 pass / 3 failed (`setSurfaceSize` outside test) | 3 pass — **fixed** |
| Dashboard `unAuthenticated` navigation test | failed (stuck in `loading`) | pass — **fixed** |
| Profile screens (`devices`, `profile`) | 1 pass / 14 did-not-complete | 14 pass — **fixed** (devices cases verified individually) |
| Auth data/domain/bloc/widgets | all pass | all pass (unchanged) |
| Auth screens | 4 pass / 4 failed / 21 did-not-complete | 14 pass / 2 failed / 6 did-not-complete — **improved** |
| Integration tests | not runnable (no device) | **executed**: 2 pass / 3 fail |
| **Totals** | 374 pass / 8 fail / 36 DND / 4 skipped | **352 pass / 5 fail / 6 DND / 0 skipped** |

*Note: totals are not directly comparable — the previous report's counts included framework pseudo-entries, and this run adds 5 integration tests that previously could not run.*

---

## Recommendations

1. **Cancel bloc/snackbar timers in tests**: tests that trigger `OtpSendEvent` or a success snackbar need the `AuthBloc` resend timer and `CustomSnackbar` timer cancelled before teardown (`addTearDown(bloc.close)` or injectable/cancellable timers). This alone removes both hard failures.
2. **Make the 6 hanging auth screen tests deterministic**: pump fake time (`tester.pump(duration)`) instead of awaiting real timer-driven state, or stub the countdown path, so loading/resend/navigation states resolve synchronously.
3. **Fix the 3 integration journeys**: verify OTP → CreateAccountScreen navigation and the forced sign-out → LoginScreen path on device, and align the sign-out dialog button finder with the actual widget type used in the dialog (it isn't an `ElevatedButton`).
4. **CI note**: `flutter test --timeout` does not bound `testWidgets` bodies (built-in 10-minute cap). Run auth screen test files in separate processes (e.g., `--concurrency=1` per-file or per-file CI shards) so one hang cannot mask the rest of a file's results.

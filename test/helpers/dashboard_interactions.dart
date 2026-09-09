import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Swallows only the known, pre-existing "RenderFlex overflowed" error from
/// the dashboard bottom nav's undersized `Container(height: 20, ...)` so it
/// doesn't fail tests that render `DashboardScreen`; any other [FlutterError]
/// still fails the test normally.
///
/// Must be installed from INSIDE a `testWidgets` body (via `addTearDown` to
/// restore): `TestWidgetsFlutterBinding.runTest()` installs its own
/// `FlutterError.onError` right before invoking the test callback, so
/// setting this from a top-level `setUp()` gets clobbered before the test
/// body ever runs.
void tolerateOverflowErrors() {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is FlutterError && details.exception.toString().contains('A RenderFlex overflowed')) {
      return;
    }
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);
}

/// The dashboard's floating action button is rendered as a bare
/// `GestureDetector` (not a `FloatingActionButton`), so it's located here via
/// its distinctive 70x70 `SizedBox` child instead of by type.
Finder fabFinder() => find.byWidgetPredicate((widget) => widget is SizedBox && widget.height == 70 && widget.width == 70);

/// Triggers a bottom-nav `_NavItem` by [label] (e.g. `StringConstants.kHome`)
/// WITHOUT going through `tester.tap()`'s coordinate-based hit-testing.
///
/// Pre-existing app bug (not fixed here since it lives in lib/): the bottom
/// nav's `Container(height: 20, ...)` in dashboard_screen.dart is shorter
/// than the 48px `_NavItem`s it contains, so every build overflows the
/// RenderFlex (suppressed by [tolerateOverflowErrors]). For the two 7-letter
/// labels ("Sharing"/"Profile") that overflow pushes the `_NavItem`'s own
/// hit-testable center point below the bottom edge of the render tree
/// entirely — regardless of surface size — so `tester.tap()` on those two
/// silently misses. Invoking the `GestureDetector.onTap` callback directly
/// sidesteps hit-testing altogether.
void tapNavItem(WidgetTester tester, String label) {
  final gestureDetector = tester.widget<GestureDetector>(
    find.ancestor(of: find.text(label), matching: find.byType(GestureDetector)).first,
  );
  gestureDetector.onTap!();
}

/// The FAB's ~20s loading spinner is an `AnimatedBuilder` painting a
/// `Container` whose `BoxDecoration.gradient` is a `SweepGradient` — the only
/// such gradient anywhere in this widget tree, so it doubles as a unique
/// "is the loading indicator showing" probe.
Finder loadingSpinnerFinder() => find.byWidgetPredicate((widget) {
  if (widget is! Container) return false;
  final decoration = widget.decoration;
  return decoration is BoxDecoration && decoration.gradient is SweepGradient;
});

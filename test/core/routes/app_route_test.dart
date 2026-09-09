import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fileflow/features/home/presentation/screens/folder_details_screen.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:fileflow/features/profile/presentation/screens/devices_screen.dart';
import 'package:fileflow/features/splash/presentation/screens/splash_screen.dart';
import 'package:fileflow/features/upload/presentation/screens/upload_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Structural checks only — these deliberately never pump any of the routed
// screens (several of them read from a fully wired `getIt`, which this test
// must not set up).
void main() {
  test('the initial location resolves to SplashScreen.routeName', () {
    expect(AppRoute.routes.routeInformationProvider.value.uri.toString(), SplashScreen.routeName);
  });

  test('registers exactly the expected top-level routes with no duplicate paths', () {
    final paths = AppRoute.routes.configuration.routes.map((route) => (route as GoRoute).path).toList();

    expect(paths, [
      SplashScreen.routeName,
      LoginScreen.routeName,
      OtpVerificationScreen.routeName,
      CreateAccountScreen.routeName,
      DashboardScreen.routeName,
      HomeScreen.routeName,
      FolderDetailsScreen.routeName,
      UploadScreen.routeName,
      DevicesScreen.routeName,
      CreateAccountScreen.editRouteName,
    ]);
    expect(paths.toSet(), hasLength(paths.length));
  });

  test('every route is a flat top-level GoRoute with no nested child routes', () {
    for (final route in AppRoute.routes.configuration.routes) {
      expect(route, isA<GoRoute>());
      expect(route.routes, isEmpty);
    }
  });
}

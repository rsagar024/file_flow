import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fileflow/features/home/presentation/screens/folder_details_screen.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:fileflow/features/profile/presentation/screens/devices_screen.dart';
import 'package:fileflow/features/upload/presentation/screens/upload_screen.dart';
import 'package:fileflow/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: SplashScreen.routeName,
    routes: [
      GoRoute(path: SplashScreen.routeName, builder: (context, state) => const SplashScreen()),
      GoRoute(path: LoginScreen.routeName, builder: (context, state) => const LoginScreen()),
      GoRoute(path: OtpVerificationScreen.routeName, builder: (context, state) => const OtpVerificationScreen()),
      GoRoute(path: CreateAccountScreen.routeName, builder: (context, state) => const CreateAccountScreen()),
      GoRoute(path: DashboardScreen.routeName, builder: (context, state) => const DashboardScreen()),
      GoRoute(path: HomeScreen.routeName, builder: (context, state) => const HomeScreen()),
      GoRoute(path: FolderDetailsScreen.routeName, builder: (context, state) => const FolderDetailsScreen()),
      GoRoute(path: UploadScreen.routeName, builder: (context, state) => const UploadScreen()),
      GoRoute(path: DevicesScreen.routeName, builder: (context, state) => const DevicesScreen()),
    ],
  );
}

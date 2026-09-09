import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fileflow/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_router_app.dart';

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

    when(() => getCurrentDeviceIdUsecase(any())).thenAnswer((_) async => const Right('device-1'));
    when(() => watchCurrentDeviceActiveStatusUsecase(any())).thenAnswer((_) => const Stream<bool>.empty());
    when(() => signOutLocalOnlyUsecase(any())).thenAnswer((_) async => const Right(null));
  });

  tearDown(() async {
    await getIt.reset();
  });

  AuthBloc buildBloc() {
    return AuthBloc(
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
  }

  GoRouter buildRouter() {
    return GoRouter(
      navigatorKey: AppRoute.navigatorKey,
      initialLocation: SplashScreen.routeName,
      routes: [
        GoRoute(path: SplashScreen.routeName, builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: LoginScreen.routeName,
          builder: (context, state) => const Scaffold(body: Text('LOGIN_STUB')),
        ),
        GoRoute(
          path: CreateAccountScreen.routeName,
          builder: (context, state) => const Scaffold(body: Text('CREATE_ACCOUNT_STUB')),
        ),
        GoRoute(
          path: DashboardScreen.routeName,
          builder: (context, state) => const Scaffold(body: Text('DASHBOARD_STUB')),
        ),
      ],
    );
  }

  group('SplashScreen', () {
    testWidgets('dispatches AuthCheckStatusEvent exactly once on init', (tester) async {
      when(() => checkAuthStatusUsecase(any())).thenAnswer(
        (_) async => const Right(AuthStatusResult(isLoggedIn: false, isNewUser: false)),
      );
      final bloc = buildBloc();
      addTearDown(bloc.close);
      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      await pumpRouterApp(tester, buildRouter(), providers: [BlocProvider<AuthBloc>.value(value: bloc)]);
      await tester.pumpAndSettle();

      verify(() => checkAuthStatusUsecase(const NoParams())).called(1);
    });

    testWidgets('unAuthenticated status navigates to LoginScreen', (tester) async {
      when(() => checkAuthStatusUsecase(any())).thenAnswer((_) async => Left(Failure('network error')));
      final bloc = buildBloc();
      addTearDown(bloc.close);
      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      await pumpRouterApp(tester, buildRouter(), providers: [BlocProvider<AuthBloc>.value(value: bloc)]);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_STUB'), findsOneWidget);
    });

    testWidgets('newUserDetected status navigates to CreateAccountScreen', (tester) async {
      when(() => checkAuthStatusUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthStatusResult(isLoggedIn: true, isNewUser: true, uid: 'uid-new', phoneNumber: '+919876543210'),
        ),
      );
      final bloc = buildBloc();
      addTearDown(bloc.close);
      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      await pumpRouterApp(tester, buildRouter(), providers: [BlocProvider<AuthBloc>.value(value: bloc)]);
      await tester.pumpAndSettle();

      expect(find.text('CREATE_ACCOUNT_STUB'), findsOneWidget);
    });

    testWidgets('authenticated status navigates to DashboardScreen', (tester) async {
      const user = UserEntity(
        uid: 'uid-active',
        devices: {'device-1': DeviceEntity(deviceId: 'device-1', isActive: true)},
      );
      when(() => checkAuthStatusUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthStatusResult(isLoggedIn: true, isNewUser: false, uid: 'uid-active', user: user),
        ),
      );
      final bloc = buildBloc();
      addTearDown(bloc.close);
      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      await pumpRouterApp(tester, buildRouter(), providers: [BlocProvider<AuthBloc>.value(value: bloc)]);
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_STUB'), findsOneWidget);
    });
  });
}

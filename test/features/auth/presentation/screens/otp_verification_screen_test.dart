import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
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

  Future<void> enterOtp(WidgetTester tester, String otp) async {
    await tester.enterText(find.byType(TextField), otp);
    await tester.pump();
  }

  group('OtpVerificationScreen', () {
    testWidgets('tapping verify with fewer than 6 digits does not dispatch OtpVerifyEvent', (tester) async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const OtpVerificationScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterOtp(tester, '123');
      await tester.tap(find.text(StringConstants.kVerify));
      await tester.pump();

      verifyNever(() => verifyOtpUsecase(any()));
    });

    testWidgets('tapping verify with the full 6-digit OTP dispatches OtpVerifyEvent with the trimmed text', (
      tester,
    ) async {
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(AuthResult(uid: 'uid-1', phoneNumber: '+919876543210', isNewUser: false)),
      );
      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — closed explicitly (fire-and-forget)
      // before the body returns instead, since awaiting close() while the
      // router/BlocListener tree is still mounted hangs under
      // AutomatedTestWidgetsFlutterBinding.

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: OtpVerificationScreen.routeName,
        routes: [
          GoRoute(
            path: OtpVerificationScreen.routeName,
            builder: (context, state) => const OtpVerificationScreen(),
          ),
          GoRoute(
            path: DashboardScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('DASHBOARD_STUB')),
          ),
        ],
      );

      await pumpRouterApp(
        tester,
        router,
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterOtp(tester, '123456');
      await tester.tap(find.text(StringConstants.kVerify));
      await tester.pumpAndSettle();

      verify(() => verifyOtpUsecase(const VerifyOtpParams('123456'))).called(1);

      bloc.close();
    });

    testWidgets('shows the initial resend countdown and does nothing when tapped while disabled', (tester) async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const OtpVerificationScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      expect(find.text('${StringConstants.kResendIn} 00:45'), findsOneWidget);

      await tester.tap(find.text('${StringConstants.kResendIn} 00:45'));
      await tester.pump();

      verifyNever(() => resendOtpUsecase(any()));
    });

    testWidgets('once canResend flips true, the resend text becomes tappable and dispatches OtpResendEvent', (
      tester,
    ) async {
      when(() => resendOtpUsecase(any())).thenAnswer((_) async => const Right('verification-id-2'));
      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — this test starts the real periodic
      // resend timer, so it closes the bloc explicitly (fire-and-forget,
      // see below) before the body returns instead.

      await pumpApp(
        tester,
        const OtpVerificationScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      // 45 ticks bring resendSeconds to 0, a 46th flips canResend to true.
      for (var i = 0; i < 46; i++) {
        bloc.add(OtpTimerTickEvent());
      }
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kResendCode), findsOneWidget);

      await tester.tap(find.text(StringConstants.kResendCode));
      await tester.pump();

      verify(() => resendOtpUsecase(any())).called(1);

      // Not awaited: with no further tester.pump() to drive the fake clock,
      // awaiting close() here hangs (same class of issue as the
      // devices_screen_test.dart teardown).
      bloc.close();
    });

    testWidgets('AuthAppStatus.failure surfaces the error message via the snackbar overlay', (tester) async {
      when(() => verifyOtpUsecase(any())).thenAnswer((_) async => Left(Failure('invalid otp')));
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const OtpVerificationScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterOtp(tester, '000000');
      await tester.tap(find.text(StringConstants.kVerify));
      await tester.pumpAndSettle();

      expect(find.text('invalid otp'), findsOneWidget);

      // CustomSnackbar schedules a 2s auto-dismiss Future.delayed that
      // pumpAndSettle doesn't necessarily wait out (it stops once no frame is
      // scheduled, not once every Timer fires); drain it explicitly so it
      // isn't still pending when the test ends.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('AuthAppStatus.newUserDetected navigates to CreateAccountScreen', (tester) async {
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(uid: 'uid-new', phoneNumber: '+919876543210', isNewUser: true),
        ),
      );
      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — closed explicitly (fire-and-forget)
      // before the body returns instead, since awaiting close() while the
      // router/BlocListener tree is still mounted hangs under
      // AutomatedTestWidgetsFlutterBinding.

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: OtpVerificationScreen.routeName,
        routes: [
          GoRoute(
            path: OtpVerificationScreen.routeName,
            builder: (context, state) => const OtpVerificationScreen(),
          ),
          GoRoute(
            path: CreateAccountScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('CREATE_ACCOUNT_STUB')),
          ),
        ],
      );

      await pumpRouterApp(
        tester,
        router,
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterOtp(tester, '123456');
      await tester.tap(find.text(StringConstants.kVerify));
      await tester.pumpAndSettle();

      expect(find.text('CREATE_ACCOUNT_STUB'), findsOneWidget);

      bloc.close();
    });

    testWidgets('AuthAppStatus.authenticated navigates to DashboardScreen', (tester) async {
      const existingUser = UserEntity(uid: 'uid-existing');
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(
            uid: 'uid-existing',
            phoneNumber: '+919876543210',
            isNewUser: false,
            existingUser: existingUser,
          ),
        ),
      );
      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — closed explicitly (fire-and-forget)
      // before the body returns instead, since awaiting close() while the
      // router/BlocListener tree is still mounted hangs under
      // AutomatedTestWidgetsFlutterBinding.

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: OtpVerificationScreen.routeName,
        routes: [
          GoRoute(
            path: OtpVerificationScreen.routeName,
            builder: (context, state) => const OtpVerificationScreen(),
          ),
          GoRoute(
            path: DashboardScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('DASHBOARD_STUB')),
          ),
        ],
      );

      await pumpRouterApp(
        tester,
        router,
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterOtp(tester, '123456');
      await tester.tap(find.text(StringConstants.kVerify));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_STUB'), findsOneWidget);

      bloc.close();
    });
  });
}

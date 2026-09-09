import 'dart:async';

import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/otp_verification_screen.dart';
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

  Future<void> enterValidPhone(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField), '9876543210');
    await tester.pump();
  }

  group('LoginScreen', () {
    testWidgets('renders the phone field with the India dial-code prefix', (tester) async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const LoginScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.textContaining('91'), findsWidgets);
      expect(find.text(StringConstants.kSendOtp), findsOneWidget);
    });

    testWidgets('tapping submit with no phone entered does not dispatch OtpSendEvent', (tester) async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const LoginScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await tester.tap(find.text(StringConstants.kSendOtp));
      await tester.pump();

      verifyNever(() => sendOtpUsecase(any()));
    });

    testWidgets('tapping submit with a valid phone dispatches OtpSendEvent with dial code + digits', (tester) async {
      when(() => sendOtpUsecase(any())).thenAnswer((_) async => const Right('verification-id-1'));
      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — this test starts the real periodic
      // resend timer, so it closes the bloc explicitly (fire-and-forget,
      // see below) before the body returns instead.

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: LoginScreen.routeName,
        routes: [
          GoRoute(path: LoginScreen.routeName, builder: (context, state) => const LoginScreen()),
          GoRoute(
            path: OtpVerificationScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('OTP_SCREEN_STUB')),
          ),
        ],
      );

      await pumpRouterApp(
        tester,
        router,
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterValidPhone(tester);
      await tester.tap(find.text(StringConstants.kSendOtp));
      await tester.pumpAndSettle();

      verify(() => sendOtpUsecase(const SendOtpParams('+919876543210'))).called(1);

      // Reaching otpSent starts AuthBloc's real periodic resend timer; cancel
      // it before the test body returns, since the framework's pending-timer
      // check runs before addTearDown(bloc.close) fires. Not awaited: with no
      // further tester.pump() to drive the fake clock, awaiting close() here
      // hangs (same class of issue as the devices_screen_test.dart teardown).
      bloc.close();
    });

    testWidgets('AuthAppStatus.loading shows a loading indicator on the submit button', (tester) async {
      final completer = Completer<Either<Failure, String>>();
      when(() => sendOtpUsecase(any())).thenAnswer((_) => completer.future);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const LoginScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterValidPhone(tester);
      await tester.tap(find.text(StringConstants.kSendOtp));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Resolve the usecase so AuthBloc's still-suspended event handler
      // completes before teardown, instead of leaving it dangling forever.
      // This triggers the failure snackbar, which schedules its own 2s
      // auto-dismiss Future.delayed — drain it too.
      completer.complete(Left(Failure('unused')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('AuthAppStatus.failure surfaces the error message via the snackbar overlay', (tester) async {
      when(() => sendOtpUsecase(any())).thenAnswer((_) async => Left(Failure('send otp failed')));
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpApp(
        tester,
        const LoginScreen(),
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterValidPhone(tester);
      await tester.tap(find.text(StringConstants.kSendOtp));
      await tester.pumpAndSettle();

      expect(find.text('send otp failed'), findsOneWidget);

      // CustomSnackbar schedules a 2s auto-dismiss Future.delayed that
      // pumpAndSettle doesn't necessarily wait out; drain it explicitly so
      // it isn't still pending when the test ends.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('AuthAppStatus.otpSent navigates to OtpVerificationScreen', (tester) async {
      when(() => sendOtpUsecase(any())).thenAnswer((_) async => const Right('verification-id-1'));
      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — this test starts the real periodic
      // resend timer, so it closes the bloc explicitly (fire-and-forget,
      // see below) before the body returns instead.

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: LoginScreen.routeName,
        routes: [
          GoRoute(path: LoginScreen.routeName, builder: (context, state) => const LoginScreen()),
          GoRoute(
            path: OtpVerificationScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('OTP_SCREEN_STUB')),
          ),
        ],
      );

      await pumpRouterApp(
        tester,
        router,
        providers: [BlocProvider<AuthBloc>.value(value: bloc)],
      );

      await enterValidPhone(tester);
      await tester.tap(find.text(StringConstants.kSendOtp));
      await tester.pumpAndSettle();

      expect(find.text('OTP_SCREEN_STUB'), findsOneWidget);

      // Reaching otpSent starts AuthBloc's real periodic resend timer; cancel
      // it before the test body returns, since the framework's pending-timer
      // check runs before addTearDown(bloc.close) fires. Not awaited: with no
      // further tester.pump() to drive the fake clock, awaiting close() here
      // hangs (same class of issue as the devices_screen_test.dart teardown).
      bloc.close();
    });
  });
}

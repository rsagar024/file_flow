import 'dart:async';

import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
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

  /// Registers [bloc] into `getIt` (matching the real `registerLazySingleton`
  /// binding CreateAccountScreen relies on via its `getIt<AuthBloc>()` field
  /// initializer) AND wraps it via `BlocProvider.value` so BlocListener /
  /// BlocBuilder / BlocSelector inside the screen resolve to the SAME
  /// instance.
  Future<void> pumpScreen(WidgetTester tester, AuthBloc bloc, {Widget? child}) async {
    getIt.registerLazySingleton<AuthBloc>(() => bloc);
    await pumpApp(
      tester,
      child ?? const CreateAccountScreen(),
      providers: [BlocProvider<AuthBloc>.value(value: bloc)],
    );
  }

  Finder saveButtonFinder(String label) => find.widgetWithText(ElevatedButton, label);

  group('CreateAccountScreen — create mode', () {
    testWidgets('empty required fields surface validation errors and no event is dispatched', (tester) async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      await pumpScreen(tester, bloc);

      await tester.tap(saveButtonFinder(StringConstants.kCreateAccount));
      await tester.pump();

      expect(find.text(StringConstants.kFullNameIsRequired), findsOneWidget);
      expect(find.text(StringConstants.kUsernameIsRequired), findsOneWidget);
      expect(find.text(StringConstants.kEmailIsRequired), findsOneWidget);
      verifyNever(() => createAccountUsecase(any()));
    });

    testWidgets('valid input dispatches CreateAccountEvent with expected params', (tester) async {
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(uid: 'uid-1', phoneNumber: '+919876543210', isNewUser: true),
        ),
      );
      when(() => createAccountUsecase(any())).thenAnswer(
        (_) async => const Right(UserEntity(uid: 'uid-1')),
      );

      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — closed explicitly (fire-and-forget)
      // before the body returns instead, since awaiting close() while the
      // router/BlocListener tree is still mounted hangs under
      // AutomatedTestWidgetsFlutterBinding.

      // Realistic precursor state: arriving here after OtpVerifyEvent flagged
      // a new user, so state.uid/phoneNumber are already populated.
      bloc.add(const OtpVerifyEvent(otp: '123456'));
      await tester.pump();
      bloc.add(const UpdateProfileImageEvent(imagePath: '/fake/local/pic.png'));
      await tester.pump();

      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: CreateAccountScreen.routeName,
        routes: [
          GoRoute(path: CreateAccountScreen.routeName, builder: (context, state) => const CreateAccountScreen()),
          GoRoute(
            path: DashboardScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('DASHBOARD_STUB')),
          ),
        ],
      );

      await pumpRouterApp(tester, router, providers: [BlocProvider<AuthBloc>.value(value: bloc)]);

      await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
      await tester.enterText(find.byType(TextField).at(1), 'janedoe');
      await tester.enterText(find.byType(TextField).at(2), 'jane@example.com');
      await tester.pump();

      await tester.tap(saveButtonFinder(StringConstants.kCreateAccount));
      await tester.pump();

      verify(
        () => createAccountUsecase(
          const CreateAccountParams(
            uid: 'uid-1',
            phoneNumber: '+919876543210',
            displayName: 'Jane Doe',
            username: 'janedoe',
            email: 'jane@example.com',
            photoUrl: '/fake/local/pic.png',
          ),
        ),
      ).called(1);

      bloc.close();
    });

    testWidgets('AuthAppStatus.loading shows a loading indicator on the submit button', (tester) async {
      final completer = Completer<Either<Failure, UserEntity>>();
      when(() => createAccountUsecase(any())).thenAnswer((_) => completer.future);
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(uid: 'uid-1', phoneNumber: '+919876543210', isNewUser: true),
        ),
      );

      final bloc = buildBloc();
      addTearDown(bloc.close);
      bloc.add(const OtpVerifyEvent(otp: '123456'));
      await tester.pump();
      bloc.add(const UpdateProfileImageEvent(imagePath: '/fake/local/pic.png'));
      await tester.pump();

      await pumpScreen(tester, bloc);

      await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
      await tester.enterText(find.byType(TextField).at(1), 'janedoe');
      await tester.enterText(find.byType(TextField).at(2), 'jane@example.com');
      await tester.pump();

      await tester.tap(saveButtonFinder(StringConstants.kCreateAccount));
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
      when(() => createAccountUsecase(any())).thenAnswer((_) async => Left(Failure('create account failed')));
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(uid: 'uid-1', phoneNumber: '+919876543210', isNewUser: true),
        ),
      );

      final bloc = buildBloc();
      addTearDown(bloc.close);
      bloc.add(const OtpVerifyEvent(otp: '123456'));
      await tester.pump();
      bloc.add(const UpdateProfileImageEvent(imagePath: '/fake/local/pic.png'));
      await tester.pump();

      await pumpScreen(tester, bloc);

      await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
      await tester.enterText(find.byType(TextField).at(1), 'janedoe');
      await tester.enterText(find.byType(TextField).at(2), 'jane@example.com');
      await tester.pump();

      await tester.tap(saveButtonFinder(StringConstants.kCreateAccount));
      await tester.pumpAndSettle();

      expect(find.text('create account failed'), findsOneWidget);

      // CustomSnackbar schedules a 2s auto-dismiss Future.delayed that
      // pumpAndSettle doesn't necessarily wait out; drain it explicitly so
      // it isn't still pending when the test ends.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('AuthAppStatus.authenticated navigates to DashboardScreen', (tester) async {
      when(() => createAccountUsecase(any())).thenAnswer(
        (_) async => const Right(UserEntity(uid: 'uid-1')),
      );
      when(() => verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(uid: 'uid-1', phoneNumber: '+919876543210', isNewUser: true),
        ),
      );

      final bloc = buildBloc();
      // No addTearDown(bloc.close) here — closed explicitly (fire-and-forget)
      // before the body returns instead, since awaiting close() while the
      // router/BlocListener tree is still mounted hangs under
      // AutomatedTestWidgetsFlutterBinding.
      bloc.add(const OtpVerifyEvent(otp: '123456'));
      await tester.pump();
      bloc.add(const UpdateProfileImageEvent(imagePath: '/fake/local/pic.png'));
      await tester.pump();

      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: CreateAccountScreen.routeName,
        routes: [
          GoRoute(path: CreateAccountScreen.routeName, builder: (context, state) => const CreateAccountScreen()),
          GoRoute(
            path: DashboardScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('DASHBOARD_STUB')),
          ),
        ],
      );

      await pumpRouterApp(tester, router, providers: [BlocProvider<AuthBloc>.value(value: bloc)]);

      await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
      await tester.enterText(find.byType(TextField).at(1), 'janedoe');
      await tester.enterText(find.byType(TextField).at(2), 'jane@example.com');
      await tester.pump();

      await tester.tap(saveButtonFinder(StringConstants.kCreateAccount));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_STUB'), findsOneWidget);

      bloc.close();
    });
  });

  group('CreateAccountScreen — edit mode', () {
    // Uses `tester.pump(...)` rather than a raw `Future.delayed(...)` to let
    // AuthCheckStatusEvent's async handler chain resolve: under
    // AutomatedTestWidgetsFlutterBinding, Timers (which back Future.delayed)
    // only advance via the test's fake clock, so an un-pumped raw delay never
    // completes and hangs the test indefinitely.
    Future<AuthBloc> buildEditModeBloc(WidgetTester tester) async {
      const existingUser = UserEntity(
        uid: 'uid-existing',
        displayName: 'Old Name',
        username: 'oldname',
        email: 'old@example.com',
        phoneNumber: '+919876543210',
        photoUrl: '/fake/local/old.png',
      );
      when(() => checkAuthStatusUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthStatusResult(isLoggedIn: true, isNewUser: false, uid: 'uid-existing', user: existingUser),
        ),
      );
      final bloc = buildBloc();
      bloc.add(AuthCheckStatusEvent());
      await tester.pump(const Duration(milliseconds: 20));
      return bloc;
    }

    testWidgets('fields are pre-filled from state.user', (tester) async {
      final bloc = await buildEditModeBloc(tester);
      addTearDown(bloc.close);

      await pumpScreen(tester, bloc);

      expect(find.text('Old Name'), findsOneWidget);
      expect(find.text('oldname'), findsOneWidget);
      expect(find.text('old@example.com'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text(StringConstants.kEditProfile), findsWidgets);
    });

    testWidgets('valid submission dispatches UpdateProfileDetailsEvent using state.imageUrl as photoUrl', (
      tester,
    ) async {
      when(() => updateProfileUsecase(any())).thenAnswer(
        (_) async => const Right(
          UserEntity(uid: 'uid-existing', displayName: 'New Name', username: 'newuser', email: 'old@example.com'),
        ),
      );
      final bloc = await buildEditModeBloc(tester);
      addTearDown(bloc.close);

      await pumpScreen(tester, bloc);

      await tester.enterText(find.byType(TextField).at(0), 'New Name');
      await tester.enterText(find.byType(TextField).at(1), 'newuser');
      await tester.pump();

      await tester.tap(saveButtonFinder(StringConstants.kSaveChanges));
      await tester.pump();

      verify(
        () => updateProfileUsecase(
          const UpdateProfileParams(
            uid: 'uid-existing',
            displayName: 'New Name',
            username: 'newuser',
            email: 'old@example.com',
          ),
        ),
      ).called(1);

      // CustomSnackbar schedules a 2s auto-dismiss Future.delayed that
      // pumpAndSettle doesn't necessarily wait out; drain it explicitly so
      // it isn't still pending when the test ends.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('profileUpdateSuccess shows a success snackbar and pops the screen', (tester) async {
      when(() => updateProfileUsecase(any())).thenAnswer(
        (_) async => const Right(UserEntity(uid: 'uid-existing', displayName: 'Old Name')),
      );
      final bloc = await buildEditModeBloc(tester);
      // No addTearDown(bloc.close) here — closed explicitly (fire-and-forget)
      // before the body returns instead, since awaiting close() while the
      // router/BlocListener tree is still mounted hangs under
      // AutomatedTestWidgetsFlutterBinding.

      getIt.registerLazySingleton<AuthBloc>(() => bloc);

      final router = GoRouter(
        navigatorKey: AppRoute.navigatorKey,
        initialLocation: '/base',
        routes: [
          GoRoute(
            path: '/base',
            builder: (context, state) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => context.push(CreateAccountScreen.editRouteName),
                  child: const Text('BASE_SCREEN'),
                ),
              ),
            ),
          ),
          GoRoute(path: CreateAccountScreen.editRouteName, builder: (context, state) => const CreateAccountScreen()),
        ],
      );

      await pumpRouterApp(tester, router, providers: [BlocProvider<AuthBloc>.value(value: bloc)]);

      await tester.tap(find.text('BASE_SCREEN'));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kEditProfile), findsWidgets);

      await tester.tap(saveButtonFinder(StringConstants.kSaveChanges));
      await tester.pumpAndSettle();

      expect(find.text(StringConstants.kProfileUpdated), findsOneWidget);
      expect(find.text('BASE_SCREEN'), findsOneWidget);
      expect(find.text(StringConstants.kSaveChanges), findsNothing);

      // CustomSnackbar schedules a 2s auto-dismiss Future.delayed that
      // pumpAndSettle doesn't necessarily wait out; drain it explicitly so
      // it isn't still pending when the test ends.
      await tester.pump(const Duration(seconds: 3));

      bloc.close();
    });

    testWidgets('profileUpdateFailure surfaces the error and does not pop the screen', (tester) async {
      when(() => updateProfileUsecase(any())).thenAnswer((_) async => Left(Failure('update failed')));
      final bloc = await buildEditModeBloc(tester);
      addTearDown(bloc.close);

      await pumpScreen(tester, bloc);

      await tester.tap(saveButtonFinder(StringConstants.kSaveChanges));
      await tester.pumpAndSettle();

      expect(find.text('update failed'), findsOneWidget);
      expect(find.text(StringConstants.kSaveChanges), findsOneWidget);

      // CustomSnackbar schedules a 2s auto-dismiss Future.delayed that
      // pumpAndSettle doesn't necessarily wait out; drain it explicitly so
      // it isn't still pending when the test ends.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}

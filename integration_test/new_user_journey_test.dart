import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../test/helpers/dashboard_interactions.dart';
import '../test/helpers/mocks.dart';
import 'helpers/integration_di.dart';
import 'helpers/pump_fileflow_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(ThemeMode.system);
  });

  testWidgets(
    'new user: unauthenticated splash -> login -> OTP -> new user detected -> create account -> dashboard',
    (tester) async {
      tolerateOverflowErrors();
      final di = setUpIntegrationDi();
      addTearDown(tearDownIntegrationDi);

      when(() => di.auth.checkAuthStatusUsecase(any())).thenAnswer(
        (_) async => const Right(AuthStatusResult(isLoggedIn: false, isNewUser: false)),
      );
      when(() => di.auth.sendOtpUsecase(any())).thenAnswer((_) async => const Right('verification-id-1'));
      when(() => di.auth.verifyOtpUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthResult(uid: 'uid-new', phoneNumber: '+919876543210', isNewUser: true),
        ),
      );
      when(() => di.auth.createAccountUsecase(any())).thenAnswer(
        (_) async => const Right(
          UserEntity(uid: 'uid-new', displayName: 'Jane Doe', username: 'janedoe', email: 'jane@example.com'),
        ),
      );

      await mockNetworkImagesFor(() async {
        await pumpFileFlowApp(tester);
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);

        // Login -> send OTP -> pushes OtpVerificationScreen.
        await tester.enterText(find.byType(TextFormField), '9876543210');
        await tester.tap(find.text(StringConstants.kSendOtp));
        await tester.pumpAndSettle();
        expect(find.byType(OtpVerificationScreen), findsOneWidget);

        // Verify OTP -> new user detected -> goes to CreateAccountScreen.
        await tester.enterText(find.byType(TextField), '123456');
        await tester.tap(find.text(StringConstants.kVerify));
        await tester.pumpAndSettle();
        expect(find.byType(CreateAccountScreen), findsOneWidget);

        // Fill in the create-account form (phone field is pre-filled/disabled
        // from state.phoneNumber, so only name/username/email need entering).
        await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
        await tester.enterText(find.byType(TextField).at(1), 'janedoe');
        await tester.enterText(find.byType(TextField).at(2), 'jane@example.com');
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, StringConstants.kCreateAccount));
        await tester.pumpAndSettle();

        // authenticated -> goes to DashboardScreen (default tab: HomeScreen).
        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text(StringConstants.kSearchInFileFlow), findsOneWidget);
      });
    },
  );
}

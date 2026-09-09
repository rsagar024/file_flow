import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fileflow/features/profile/presentation/screens/devices_screen.dart';
import 'package:fileflow/features/profile/presentation/screens/profile_screen.dart';
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
    'sign-out: Profile -> Devices (verify list) -> back -> Logout confirm -> unAuthenticated -> LoginScreen',
    (tester) async {
      tolerateOverflowErrors();
      final di = setUpIntegrationDi();
      addTearDown(tearDownIntegrationDi);

      when(() => di.auth.checkAuthStatusUsecase(any())).thenAnswer(
        (_) async => const Right(
          AuthStatusResult(
            isLoggedIn: true,
            isNewUser: false,
            uid: 'uid-1',
            user: UserEntity(
              uid: 'uid-1',
              displayName: 'Jane Doe',
              devices: {'device-1': DeviceEntity(deviceId: 'device-1', isActive: true)},
            ),
          ),
        ),
      );
      when(() => di.devices.getCurrentDeviceIdUsecase(any())).thenAnswer((_) async => const Right('device-1'));
      when(() => di.devices.watchDevicesUsecase(any())).thenAnswer(
        (_) => Stream.value(const [
          DeviceEntity(deviceId: 'device-1', deviceName: 'This Phone', isActive: true),
          DeviceEntity(deviceId: 'device-2', deviceName: 'Old Tablet', isActive: true),
        ]),
      );
      when(() => di.auth.signOutUsecase(any())).thenAnswer((_) async => const Right(null));

      await mockNetworkImagesFor(() async {
        await pumpFileFlowApp(tester);
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);

        tapNavItem(tester, StringConstants.kProfile);
        await tester.pumpAndSettle();
        expect(find.byType(ProfileScreen), findsOneWidget);

        // Profile -> Devices (real push route through the actual AppRoute
        // table, real DevicesBloc resolved from getIt).
        await tester.tap(find.widgetWithText(ListTile, StringConstants.kDevices));
        await tester.pumpAndSettle();
        expect(find.byType(DevicesScreen), findsOneWidget);
        expect(find.text('Old Tablet'), findsOneWidget);

        // Back to Profile.
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(DevicesScreen), findsNothing);
        expect(find.byType(ProfileScreen), findsOneWidget);

        // Logout: tap the ListTile -> ConfirmationDialogWidget -> confirm.
        // The dialog's confirm button label ("Logout") collides with the
        // underlying ListTile's own text, so the finder must be scoped to
        // the Dialog itself.
        await tester.tap(find.widgetWithText(ListTile, StringConstants.kLogout));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.widgetWithText(ElevatedButton, StringConstants.kLogout),
          ),
        );
        await tester.pumpAndSettle();

        // SignOutEvent -> unAuthenticated -> DashboardScreen's own
        // BlocListener navigates back to LoginScreen through the real route
        // table.
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);
      });
    },
  );
}

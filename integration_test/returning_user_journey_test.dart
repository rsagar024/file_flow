import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
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

  testWidgets('returning user with an active own device: splash lands directly on DashboardScreen', (tester) async {
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

    await mockNetworkImagesFor(() async {
      await pumpFileFlowApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });

  testWidgets(
    'returning user whose own device was remotely deactivated: splash forces sign-out and lands on LoginScreen',
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
              devices: {'device-1': DeviceEntity(deviceId: 'device-1', isActive: false)},
            ),
          ),
        ),
      );

      await mockNetworkImagesFor(() async {
        await pumpFileFlowApp(tester);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);
      });
    },
  );
}

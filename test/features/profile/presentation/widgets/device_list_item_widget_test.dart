import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/profile/presentation/widgets/device_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Widget wrap(Widget child) => Scaffold(body: child);

  group('DeviceListItemWidget', () {
    testWidgets('renders device name, platform icon, and model + relative time subtitle', (tester) async {
      final device = DeviceEntity(
        deviceId: 'device-1',
        deviceName: 'Pixel 8',
        deviceModel: 'Pixel 8 Pro',
        platform: 'android',
        lastLoginAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
      );

      await pumpApp(tester, wrap(DeviceListItemWidget(device: device, isCurrentDevice: false)));

      expect(find.text('Pixel 8'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.textContaining('Pixel 8 Pro'), findsOneWidget);
      expect(find.textContaining('10${StringConstants.kMinutesAgoSuffix}'), findsOneWidget);
    });

    testWidgets('falls back to "Unknown device" when deviceName is null/empty', (tester) async {
      const device = DeviceEntity(deviceId: 'device-1', platform: 'ios');

      await pumpApp(tester, wrap(const DeviceListItemWidget(device: device, isCurrentDevice: false)));

      expect(find.text(StringConstants.kUnknownDevice), findsOneWidget);
      expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
    });

    testWidgets('unknown platform shows the generic devices icon', (tester) async {
      const device = DeviceEntity(deviceId: 'device-1', deviceName: 'Some Laptop', platform: 'windows');

      await pumpApp(tester, wrap(const DeviceListItemWidget(device: device, isCurrentDevice: false)));

      expect(find.byIcon(Icons.devices_other), findsOneWidget);
    });

    testWidgets('current device shows the "This device" badge and no logout affordance', (tester) async {
      const device = DeviceEntity(deviceId: 'device-1', deviceName: 'My Phone', platform: 'android');

      await pumpApp(tester, wrap(const DeviceListItemWidget(device: device, isCurrentDevice: true)));

      expect(find.text(StringConstants.kThisDevice), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('non-current device shows a logout button that invokes onLogout when tapped', (tester) async {
      const device = DeviceEntity(deviceId: 'device-2', deviceName: 'Other Phone', platform: 'android');
      var tapped = false;

      await pumpApp(
        tester,
        wrap(
          DeviceListItemWidget(
            device: device,
            isCurrentDevice: false,
            onLogout: () => tapped = true,
          ),
        ),
      );

      expect(find.text(StringConstants.kThisDevice), findsNothing);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('isLoggingOut:true replaces the logout button with a spinner for a non-current device', (
      tester,
    ) async {
      const device = DeviceEntity(deviceId: 'device-2', deviceName: 'Other Phone', platform: 'android');

      await pumpApp(
        tester,
        wrap(const DeviceListItemWidget(device: device, isCurrentDevice: false, isLoggingOut: true)),
      );

      expect(find.byIcon(Icons.logout), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

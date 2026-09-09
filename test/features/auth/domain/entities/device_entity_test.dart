import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lastLoginAt = DateTime(2024, 3, 3, 10, 30);

  DeviceEntity buildDevice({
    String? deviceId = 'device-1',
    String? deviceName = 'Pixel 8',
    String? deviceModel = 'Pixel',
    String? platform = 'android',
    String? appVersion = '1.0.0',
    String? fcmToken = 'token-abc',
    bool? isActive = true,
    DateTime? lastLoginAtValue,
  }) {
    return DeviceEntity(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceModel: deviceModel,
      platform: platform,
      appVersion: appVersion,
      fcmToken: fcmToken,
      isActive: isActive,
      lastLoginAt: lastLoginAtValue ?? lastLoginAt,
    );
  }

  group('equality', () {
    test('two instances with identical fields are equal', () {
      expect(buildDevice(), buildDevice());
    });

    test('a differing field breaks equality', () {
      expect(buildDevice(), isNot(equals(buildDevice(deviceName: 'Other Name'))));
      expect(buildDevice(), isNot(equals(buildDevice(isActive: false))));
      expect(buildDevice(), isNot(equals(buildDevice(deviceId: 'device-2'))));
    });
  });

  group('copyWith', () {
    test('overrides only the given fields and preserves the rest', () {
      final original = buildDevice();
      final copy = original.copyWith(deviceName: 'New Name');

      expect(copy.deviceName, 'New Name');
      expect(copy.deviceId, original.deviceId);
      expect(copy.deviceModel, original.deviceModel);
      expect(copy.platform, original.platform);
      expect(copy.appVersion, original.appVersion);
      expect(copy.fcmToken, original.fcmToken);
      expect(copy.isActive, original.isActive);
      expect(copy.lastLoginAt, original.lastLoginAt);
    });

    test('deviceId can be overridden via copyWith', () {
      final original = buildDevice(deviceId: 'device-1');
      final copy = original.copyWith(deviceId: 'device-2');

      expect(copy.deviceId, 'device-2');
    });
  });

  group('toModel', () {
    test('maps every field 1:1 onto DeviceModel', () {
      final entity = buildDevice();
      final model = entity.toModel();

      expect(model.deviceId, entity.deviceId);
      expect(model.deviceName, entity.deviceName);
      expect(model.deviceModel, entity.deviceModel);
      expect(model.platform, entity.platform);
      expect(model.appVersion, entity.appVersion);
      expect(model.fcmToken, entity.fcmToken);
      expect(model.isActive, entity.isActive);
      expect(model.lastLoginAt, entity.lastLoginAt);
    });
  });
}

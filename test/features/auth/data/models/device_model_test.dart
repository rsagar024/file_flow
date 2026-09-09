import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lastLoginAt = DateTime.utc(2024, 5, 6, 12, 30);

  Map<String, dynamic> fullJson() => {
    'deviceId': 'device-1',
    'deviceName': 'Pixel 8',
    'deviceModel': 'Pixel',
    'platform': 'android',
    'appVersion': '1.2.3',
    'fcmToken': 'token-abc',
    'isActive': true,
    'lastLoginAt': lastLoginAt.toIso8601String(),
  };

  group('fromJson/toJson round trip', () {
    test('fully-populated json round-trips', () {
      final json = fullJson();
      final model = DeviceModel.fromJson(json);

      expect(model.deviceId, 'device-1');
      expect(model.deviceName, 'Pixel 8');
      expect(model.deviceModel, 'Pixel');
      expect(model.platform, 'android');
      expect(model.appVersion, '1.2.3');
      expect(model.fcmToken, 'token-abc');
      expect(model.isActive, true);
      expect(model.lastLoginAt, lastLoginAt);

      expect(model.toJson(), json);
    });

    test('lastLoginAt ISO8601 string parses back to an equivalent DateTime', () {
      final model = DeviceModel.fromJson(fullJson());
      expect(model.lastLoginAt, isNotNull);
      expect(model.lastLoginAt!.toIso8601String(), lastLoginAt.toIso8601String());
    });
  });

  group('null-handling for optional fields', () {
    test('fromJson with all fields absent produces an all-null model', () {
      final model = DeviceModel.fromJson(const {});

      expect(model.deviceId, isNull);
      expect(model.deviceName, isNull);
      expect(model.deviceModel, isNull);
      expect(model.platform, isNull);
      expect(model.appVersion, isNull);
      expect(model.fcmToken, isNull);
      expect(model.isActive, isNull);
      expect(model.lastLoginAt, isNull);
    });

    test('toJson with null lastLoginAt produces a null lastLoginAt entry', () {
      const model = DeviceModel(deviceId: 'device-1');
      final json = model.toJson();

      expect(json['lastLoginAt'], isNull);
      expect(json['deviceId'], 'device-1');
    });
  });

  group('toEntity', () {
    test('maps every field 1:1 onto DeviceEntity', () {
      final model = DeviceModel.fromJson(fullJson());
      final entity = model.toEntity();

      expect(entity.deviceId, model.deviceId);
      expect(entity.deviceName, model.deviceName);
      expect(entity.deviceModel, model.deviceModel);
      expect(entity.platform, model.platform);
      expect(entity.appVersion, model.appVersion);
      expect(entity.fcmToken, model.fcmToken);
      expect(entity.isActive, model.isActive);
      expect(entity.lastLoginAt, model.lastLoginAt);
    });
  });
}

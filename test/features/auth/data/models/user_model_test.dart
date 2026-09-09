import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:fileflow/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime.utc(2024, 1, 1);
  final updatedAt = DateTime.utc(2024, 2, 2);
  final lastLoginAt = DateTime.utc(2024, 3, 3);

  Map<String, dynamic> deviceJson() => {
    'deviceId': 'device-1',
    'deviceName': 'Pixel 8',
    'deviceModel': 'Pixel',
    'platform': 'android',
    'appVersion': '1.2.3',
    'fcmToken': 'token-abc',
    'isActive': true,
    'lastLoginAt': lastLoginAt.toIso8601String(),
  };

  Map<String, dynamic> fullJson() => {
    'uid': 'uid-1',
    'email': 'user@example.com',
    'displayName': 'Display Name',
    'username': 'username',
    'photoUrl': 'https://example.com/photo.png',
    'phoneNumber': '+10000000000',
    'storageUsedBytes': 1024,
    'storageLimitBytes': 2048,
    'totalFilesCount': 5,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'devices': {'device-1': deviceJson()},
    'isNewUser': false,
  };

  group('fromJson/toJson round trip', () {
    test('fully-populated json round-trips', () {
      final json = fullJson();
      final model = UserModel.fromJson(json);

      expect(model.uid, 'uid-1');
      expect(model.email, 'user@example.com');
      expect(model.displayName, 'Display Name');
      expect(model.username, 'username');
      expect(model.photoUrl, 'https://example.com/photo.png');
      expect(model.phoneNumber, '+10000000000');
      expect(model.storageUsedBytes, 1024);
      expect(model.storageLimitBytes, 2048);
      expect(model.totalFilesCount, 5);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
      expect(model.isNewUser, false);
      expect(model.devices, isNotNull);
      expect(model.devices!['device-1']!.deviceId, 'device-1');

      expect(model.toJson(), json);
    });

    test('fromJson defaults isNewUser to false when absent', () {
      final model = UserModel.fromJson(const {});
      expect(model.isNewUser, false);
    });
  });

  group('_parseDevices via fromJson', () {
    test('devices absent produces null', () {
      final json = fullJson()..remove('devices');
      final model = UserModel.fromJson(json);
      expect(model.devices, isNull);
    });

    test('devices explicitly null produces null', () {
      final json = fullJson()..['devices'] = null;
      final model = UserModel.fromJson(json);
      expect(model.devices, isNull);
    });

    test('devices as a proper Map<String, Map> parses into Map<String, DeviceModel>', () {
      final json = fullJson();
      json['devices'] = {
        'device-1': deviceJson(),
        'device-2': {'deviceId': 'device-2', 'deviceName': 'iPhone'},
      };
      final model = UserModel.fromJson(json);

      expect(model.devices, isA<Map<String, DeviceModel>>());
      expect(model.devices!.keys, {'device-1', 'device-2'});
      expect(model.devices!['device-1']!.deviceName, 'Pixel 8');
      expect(model.devices!['device-2']!.deviceName, 'iPhone');
    });

    test('fromJson tolerates legacy List-shaped devices field by dropping it (empty list)', () {
      final json = fullJson();
      json['devices'] = <dynamic>[];

      UserModel? model;
      expect(() => model = UserModel.fromJson(json), returnsNormally);
      expect(model!.devices, isNull);
    });

    test('fromJson tolerates legacy List-shaped devices field by dropping it (populated list)', () {
      final json = fullJson();
      json['devices'] = [
        {'deviceId': 'x'},
      ];

      UserModel? model;
      expect(() => model = UserModel.fromJson(json), returnsNormally);
      expect(model!.devices, isNull);
    });
  });

  group('toJson devices shape', () {
    test('toJson always produces a Map<String,dynamic> for devices, never a List', () {
      final json = fullJson();
      final model = UserModel.fromJson(json);
      final encoded = model.toJson();

      expect(encoded['devices'], isA<Map<String, dynamic>>());
      expect(encoded['devices'], isNot(isA<List>()));
      final devicesMap = encoded['devices'] as Map<String, dynamic>;
      expect(devicesMap['device-1'], (model.devices!['device-1'] as DeviceModel).toJson());
    });

    test('toJson produces null devices when the model has no devices', () {
      const model = UserModel(uid: 'uid-1');
      expect(model.toJson()['devices'], isNull);
    });
  });

  group('toEntity', () {
    test('maps every field including devices onto UserEntity', () {
      final model = UserModel.fromJson(fullJson());
      final entity = model.toEntity();

      expect(entity.uid, model.uid);
      expect(entity.email, model.email);
      expect(entity.displayName, model.displayName);
      expect(entity.username, model.username);
      expect(entity.photoUrl, model.photoUrl);
      expect(entity.phoneNumber, model.phoneNumber);
      expect(entity.storageUsedBytes, model.storageUsedBytes);
      expect(entity.storageLimitBytes, model.storageLimitBytes);
      expect(entity.totalFilesCount, model.totalFilesCount);
      expect(entity.createdAt, model.createdAt);
      expect(entity.updatedAt, model.updatedAt);
      expect(entity.isNewUser, model.isNewUser);
      expect(entity.devices!['device-1']!.deviceId, model.devices!['device-1']!.deviceId);
    });
  });
}

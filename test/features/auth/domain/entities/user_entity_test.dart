import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2024, 1, 1);
  final updatedAt = DateTime(2024, 2, 2);
  final devices = <String, DeviceEntity>{
    'device-1': const DeviceEntity(deviceId: 'device-1', deviceName: 'Pixel'),
  };

  UserEntity buildUser({
    String? uid = 'uid-1',
    String? email = 'user@example.com',
    String? displayName = 'Display Name',
    String? username = 'username',
    String? photoUrl = 'https://example.com/photo.png',
    String? phoneNumber = '+10000000000',
    int? storageUsedBytes = 1024,
    int? storageLimitBytes = 2048,
    int? totalFilesCount = 5,
    DateTime? createdAtValue,
    DateTime? updatedAtValue,
    Map<String, DeviceEntity>? devicesValue,
    bool includeDevices = true,
    bool isNewUser = false,
  }) {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      username: username,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      storageUsedBytes: storageUsedBytes,
      storageLimitBytes: storageLimitBytes,
      totalFilesCount: totalFilesCount,
      createdAt: createdAtValue ?? createdAt,
      updatedAt: updatedAtValue ?? updatedAt,
      devices: includeDevices ? (devicesValue ?? devices) : null,
      isNewUser: isNewUser,
    );
  }

  group('equality', () {
    test('two instances with identical fields are equal', () {
      expect(buildUser(), buildUser());
    });

    test('a differing field breaks equality', () {
      expect(buildUser(), isNot(equals(buildUser(displayName: 'Someone Else'))));
      expect(buildUser(), isNot(equals(buildUser(uid: 'different-uid'))));
      expect(buildUser(), isNot(equals(buildUser(isNewUser: true))));
    });
  });

  group('copyWith', () {
    test('overrides only the given fields and preserves the rest', () {
      final original = buildUser();
      final copy = original.copyWith(displayName: 'New Name');

      expect(copy.displayName, 'New Name');
      expect(copy.uid, original.uid);
      expect(copy.email, original.email);
      expect(copy.username, original.username);
      expect(copy.photoUrl, original.photoUrl);
      expect(copy.phoneNumber, original.phoneNumber);
      expect(copy.storageUsedBytes, original.storageUsedBytes);
      expect(copy.storageLimitBytes, original.storageLimitBytes);
      expect(copy.totalFilesCount, original.totalFilesCount);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
      expect(copy.devices, original.devices);
      expect(copy.isNewUser, original.isNewUser);
    });

    test('copyWith has no uid parameter — uid can never be overridden via copyWith', () {
      final original = buildUser(uid: 'original-uid');
      // copyWith's signature intentionally omits `uid`, so the resulting
      // instance always keeps the original uid regardless of what else changes.
      final copy = original.copyWith(email: 'new@example.com');

      expect(copy.uid, 'original-uid');
    });

    test('isNewUser can be overridden via copyWith', () {
      final original = buildUser(isNewUser: false);
      final copy = original.copyWith(isNewUser: true);

      expect(copy.isNewUser, isTrue);
    });
  });

  group('toModel', () {
    test('maps every field 1:1 onto UserModel', () {
      final entity = buildUser();
      final model = entity.toModel();

      expect(model.uid, entity.uid);
      expect(model.email, entity.email);
      expect(model.displayName, entity.displayName);
      expect(model.username, entity.username);
      expect(model.photoUrl, entity.photoUrl);
      expect(model.phoneNumber, entity.phoneNumber);
      expect(model.storageUsedBytes, entity.storageUsedBytes);
      expect(model.storageLimitBytes, entity.storageLimitBytes);
      expect(model.totalFilesCount, entity.totalFilesCount);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
      expect(model.isNewUser, entity.isNewUser);
      expect(model.devices!.keys, entity.devices!.keys);
      for (final key in entity.devices!.keys) {
        expect(model.devices![key]!.deviceId, entity.devices![key]!.deviceId);
        expect(model.devices![key]!.deviceName, entity.devices![key]!.deviceName);
      }
    });

    test('maps null devices to null', () {
      final entity = buildUser(includeDevices: false);
      expect(entity.toModel().devices, isNull);
    });
  });

  group('storageUsedPercentage', () {
    test('returns 0.0 when storageLimitBytes is null', () {
      final entity = buildUser(storageUsedBytes: 100, storageLimitBytes: null);
      expect(entity.storageUsedPercentage, 0.0);
    });

    test('returns 0.0 when storageLimitBytes is 0', () {
      final entity = buildUser(storageUsedBytes: 100, storageLimitBytes: 0);
      expect(entity.storageUsedPercentage, 0.0);
    });

    test('returns 0.0 when storageUsedBytes is null', () {
      final entity = buildUser(storageUsedBytes: null, storageLimitBytes: 1000);
      expect(entity.storageUsedPercentage, 0.0);
    });

    test('computes percentage when both values are present', () {
      final entity = buildUser(storageUsedBytes: 50, storageLimitBytes: 200);
      expect(entity.storageUsedPercentage, 25.0);
    });

    test('can exceed 100 when used bytes exceed the limit', () {
      final entity = buildUser(storageUsedBytes: 400, storageLimitBytes: 200);
      expect(entity.storageUsedPercentage, 200.0);
    });
  });

  group('storageUsedFormatted', () {
    test('0 bytes', () {
      final entity = buildUser(storageUsedBytes: 0);
      expect(entity.storageUsedFormatted, '0 B');
    });

    test('null storageUsedBytes formats as 0 B', () {
      final entity = buildUser(storageUsedBytes: null);
      expect(entity.storageUsedFormatted, '0 B');
    });

    test('small byte value stays in bytes', () {
      final entity = buildUser(storageUsedBytes: 512);
      expect(entity.storageUsedFormatted, '512 B');
    });

    test('KB-range value', () {
      final entity = buildUser(storageUsedBytes: 2048);
      expect(entity.storageUsedFormatted, '2.0 KB');
    });

    test('MB-range value', () {
      final entity = buildUser(storageUsedBytes: 5 * 1024 * 1024);
      expect(entity.storageUsedFormatted, '5.0 MB');
    });

    test('GB-range value', () {
      final entity = buildUser(storageUsedBytes: 3 * 1024 * 1024 * 1024);
      expect(entity.storageUsedFormatted, '3.0 GB');
    });
  });

  group('storageLimitFormatted', () {
    test('null storageLimitBytes formats as 0.0 GB', () {
      final entity = buildUser(storageLimitBytes: null);
      expect(entity.storageLimitFormatted, '0.0 GB');
    });

    test('0 storageLimitBytes formats as 0.0 GB', () {
      final entity = buildUser(storageLimitBytes: 0);
      expect(entity.storageLimitFormatted, '0.0 GB');
    });

    test('GB-range value', () {
      final entity = buildUser(storageLimitBytes: 10 * 1024 * 1024 * 1024);
      expect(entity.storageLimitFormatted, '10.0 GB');
    });
  });
}

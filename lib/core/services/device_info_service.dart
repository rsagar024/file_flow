import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceInfoService({DeviceInfoPlugin? deviceInfoPlugin}) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  Future<DeviceEntity> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final now = DateTime.now().toUtc();

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return DeviceEntity(
        deviceId: androidInfo.id,
        deviceName: androidInfo.brand,
        deviceModel: androidInfo.model,
        platform: 'android',
        appVersion: packageInfo.version,
        fcmToken: null,
        isActive: true,
        lastLoginAt: now,
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return DeviceEntity(
        deviceId: iosInfo.identifierForVendor ?? 'unknown_ios',
        deviceName: iosInfo.name,
        deviceModel: iosInfo.model,
        platform: 'ios',
        appVersion: packageInfo.version,
        fcmToken: null,
        isActive: true,
        lastLoginAt: now,
      );
    }

    return DeviceEntity(
      deviceId: 'unknown',
      deviceName: 'unknown Device',
      platform: 'unknown',
      isActive: true,
      lastLoginAt: now,
    );
  }
}

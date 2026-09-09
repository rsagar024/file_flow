import 'package:fileflow/core/services/device_info_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

// This suite runs on a Windows host, where `dart:io Platform.isAndroid`/
// `Platform.isIOS` are both false and cannot be overridden from a plain
// `test()` (there's no test-facing seam for `dart:io Platform` the way
// there is for `defaultTargetPlatform`). So only DeviceInfoService's
// "unknown platform" fallback branch is actually reachable here — the
// Android/iOS branches (which additionally call through to
// `DeviceInfoPlugin.androidInfo`/`.iosInfo`) are exercised by manual/device
// testing instead, not by this unit test.
void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'FileFlow',
      packageName: 'com.fileflow.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  test('falls back to an "unknown" DeviceEntity on a non-Android/iOS platform', () async {
    final service = DeviceInfoService();

    final result = await service.getDeviceInfo();

    expect(result.deviceId, 'unknown');
    expect(result.deviceName, 'unknown Device');
    expect(result.platform, 'unknown');
    expect(result.isActive, isTrue);
    expect(result.lastLoginAt, isNotNull);
    expect(result.deviceModel, isNull);
    expect(result.appVersion, isNull);
    expect(result.fcmToken, isNull);
  });
}

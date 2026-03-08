import 'package:fileflow/features/auth/domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    super.deviceId,
    super.deviceName,
    super.deviceModel,
    super.platform,
    super.appVersion,
    super.fcmToken,
    super.isActive,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceModel: json['deviceModel'] as String?,
      platform: json['platform'] as String?,
      appVersion: json['appVersion'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'platform': platform,
      'appVersion': appVersion,
      'fcmToken': fcmToken,
      'isActive': isActive,
    };
  }

  DeviceEntity toEntity() {
    return DeviceEntity(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceModel: deviceModel,
      platform: platform,
      appVersion: appVersion,
      fcmToken: fcmToken,
      isActive: isActive,
    );
  }
}

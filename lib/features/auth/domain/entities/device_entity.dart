import 'package:equatable/equatable.dart';
import 'package:fileflow/features/auth/data/models/device_model.dart';

class DeviceEntity extends Equatable {
  final String? deviceId;
  final String? deviceName;
  final String? deviceModel;
  final String? platform;
  final String? appVersion;
  final String? fcmToken;
  final bool? isActive;

  const DeviceEntity({
    this.deviceId,
    this.deviceName,
    this.deviceModel,
    this.platform,
    this.appVersion,
    this.fcmToken,
    this.isActive,
  });

  @override
  List<Object?> get props => [deviceId, deviceName, deviceModel, platform, appVersion, fcmToken, isActive];

  DeviceEntity copyWith({
    String? deviceId,
    String? deviceName,
    String? deviceModel,
    String? platform,
    String? appVersion,
    String? fcmToken,
    bool? isActive,
  }) {
    return DeviceEntity(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceModel: deviceModel ?? this.deviceModel,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
    );
  }

  DeviceModel toModel() {
    return DeviceModel(
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

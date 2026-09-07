part of 'devices_bloc.dart';

enum DevicesStatus { initial, loading, loaded, failure }

class DevicesState extends Equatable {
  final DevicesStatus status;
  final List<DeviceEntity> devices;
  final String? currentDeviceId;
  final String? actionInProgressDeviceId;
  final bool isLogoutAllInProgress;
  final String? errorMessage;

  const DevicesState({
    this.status = DevicesStatus.initial,
    this.devices = const [],
    this.currentDeviceId,
    this.actionInProgressDeviceId,
    this.isLogoutAllInProgress = false,
    this.errorMessage,
  });

  List<DeviceEntity> get otherDevices =>
      devices.where((d) => d.deviceId != currentDeviceId).toList();

  DevicesState copyWith({
    DevicesStatus? status,
    List<DeviceEntity>? devices,
    String? currentDeviceId,
    String? actionInProgressDeviceId,
    bool clearActionInProgressDeviceId = false,
    bool? isLogoutAllInProgress,
    String? errorMessage,
  }) {
    return DevicesState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      actionInProgressDeviceId: clearActionInProgressDeviceId
          ? null
          : (actionInProgressDeviceId ?? this.actionInProgressDeviceId),
      isLogoutAllInProgress:
          isLogoutAllInProgress ?? this.isLogoutAllInProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    devices,
    currentDeviceId,
    actionInProgressDeviceId,
    isLogoutAllInProgress,
    errorMessage,
  ];
}

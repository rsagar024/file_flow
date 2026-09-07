part of 'devices_bloc.dart';

sealed class DevicesEvent extends Equatable {
  const DevicesEvent();

  @override
  List<Object?> get props => [];
}

final class DevicesSubscribeRequested extends DevicesEvent {
  final String uid;

  const DevicesSubscribeRequested({required this.uid});

  @override
  List<Object?> get props => [uid];
}

final class _DevicesListUpdated extends DevicesEvent {
  final List<DeviceEntity> devices;

  const _DevicesListUpdated(this.devices);

  @override
  List<Object?> get props => [devices];
}

final class DevicesLogoutOneRequested extends DevicesEvent {
  final String deviceId;

  const DevicesLogoutOneRequested({required this.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

final class DevicesLogoutAllOthersRequested extends DevicesEvent {
  const DevicesLogoutAllOthersRequested();
}

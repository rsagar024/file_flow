import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/get_current_device_id_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_all_other_devices_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_device_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_devices_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'devices_event.dart';

part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final WatchDevicesUsecase _watchDevicesUsecase;
  final GetCurrentDeviceIdUsecase _getCurrentDeviceIdUsecase;
  final LogoutDeviceUsecase _logoutDeviceUsecase;
  final LogoutAllOtherDevicesUsecase _logoutAllOtherDevicesUsecase;

  StreamSubscription<List<DeviceEntity>>? _devicesSubscription;
  String? _uid;

  DevicesBloc(
    this._watchDevicesUsecase,
    this._getCurrentDeviceIdUsecase,
    this._logoutDeviceUsecase,
    this._logoutAllOtherDevicesUsecase,
  ) : super(const DevicesState()) {
    on<DevicesSubscribeRequested>(_onSubscribe);
    on<_DevicesListUpdated>(_onDevicesListUpdated);
    on<DevicesLogoutOneRequested>(_onLogoutOne);
    on<DevicesLogoutAllOthersRequested>(_onLogoutAllOthers);
  }

  Future<void> _onSubscribe(
    DevicesSubscribeRequested event,
    Emitter<DevicesState> emit,
  ) async {
    _uid = event.uid;
    emit(state.copyWith(status: DevicesStatus.loading));

    final idResult = await _getCurrentDeviceIdUsecase(const NoParams());
    idResult.fold(
      (failure) => emit(
        state.copyWith(
          status: DevicesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (deviceId) => emit(state.copyWith(currentDeviceId: deviceId)),
    );

    await _devicesSubscription?.cancel();
    _devicesSubscription = _watchDevicesUsecase(
      event.uid,
    ).listen((devices) => add(_DevicesListUpdated(devices)));
  }

  void _onDevicesListUpdated(
    _DevicesListUpdated event,
    Emitter<DevicesState> emit,
  ) {
    emit(state.copyWith(status: DevicesStatus.loaded, devices: event.devices));
  }

  Future<void> _onLogoutOne(
    DevicesLogoutOneRequested event,
    Emitter<DevicesState> emit,
  ) async {
    if (_uid == null) return;
    emit(state.copyWith(actionInProgressDeviceId: event.deviceId));

    final result = await _logoutDeviceUsecase(
      LogoutDeviceParams(uid: _uid!, deviceId: event.deviceId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          clearActionInProgressDeviceId: true,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(clearActionInProgressDeviceId: true)),
    );
  }

  Future<void> _onLogoutAllOthers(
    DevicesLogoutAllOthersRequested event,
    Emitter<DevicesState> emit,
  ) async {
    if (_uid == null || state.currentDeviceId == null) return;
    emit(state.copyWith(isLogoutAllInProgress: true));

    final result = await _logoutAllOtherDevicesUsecase(
      LogoutAllOtherDevicesParams(
        uid: _uid!,
        currentDeviceId: state.currentDeviceId!,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLogoutAllInProgress: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(isLogoutAllInProgress: false)),
    );
  }

  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    return super.close();
  }
}

import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';

class WatchDevicesUsecase implements StreamUseCase<List<DeviceEntity>, String> {
  final AuthRepository _authRepository;

  const WatchDevicesUsecase(this._authRepository);

  @override
  Stream<List<DeviceEntity>> call(String uid) {
    return _authRepository.watchDevices(uid);
  }
}

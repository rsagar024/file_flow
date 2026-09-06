import 'package:equatable/equatable.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';

class WatchCurrentDeviceActiveStatusUsecase
    implements StreamUseCase<bool, WatchCurrentDeviceActiveStatusParams> {
  final AuthRepository _authRepository;

  const WatchCurrentDeviceActiveStatusUsecase(this._authRepository);

  @override
  Stream<bool> call(WatchCurrentDeviceActiveStatusParams params) {
    return _authRepository.watchCurrentDeviceActiveStatus(
      params.uid,
      params.deviceId,
    );
  }
}

class WatchCurrentDeviceActiveStatusParams extends Equatable {
  final String uid;
  final String deviceId;

  const WatchCurrentDeviceActiveStatusParams({
    required this.uid,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [uid, deviceId];
}

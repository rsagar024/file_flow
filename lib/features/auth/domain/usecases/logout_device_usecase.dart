import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogoutDeviceUsecase implements Usecase<void, LogoutDeviceParams> {
  final AuthRepository _authRepository;

  const LogoutDeviceUsecase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(LogoutDeviceParams params) {
    return _authRepository.logoutDevice(
      uid: params.uid,
      deviceId: params.deviceId,
    );
  }
}

class LogoutDeviceParams extends Equatable {
  final String uid;
  final String deviceId;

  const LogoutDeviceParams({required this.uid, required this.deviceId});

  @override
  List<Object?> get props => [uid, deviceId];
}

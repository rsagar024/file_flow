import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogoutAllOtherDevicesUsecase
    implements Usecase<void, LogoutAllOtherDevicesParams> {
  final AuthRepository _authRepository;

  const LogoutAllOtherDevicesUsecase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(LogoutAllOtherDevicesParams params) {
    return _authRepository.logoutAllOtherDevices(
      uid: params.uid,
      currentDeviceId: params.currentDeviceId,
    );
  }
}

class LogoutAllOtherDevicesParams extends Equatable {
  final String uid;
  final String currentDeviceId;

  const LogoutAllOtherDevicesParams({
    required this.uid,
    required this.currentDeviceId,
  });

  @override
  List<Object?> get props => [uid, currentDeviceId];
}

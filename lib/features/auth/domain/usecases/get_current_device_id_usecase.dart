import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentDeviceIdUsecase implements Usecase<String, NoParams> {
  final AuthRepository _authRepository;

  const GetCurrentDeviceIdUsecase(this._authRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return _authRepository.getCurrentDeviceId();
  }
}

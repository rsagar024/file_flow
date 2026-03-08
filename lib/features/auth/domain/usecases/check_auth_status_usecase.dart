import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckAuthStatusUsecase implements Usecase<AuthStatusResult, NoParams> {
  final AuthRepository _authRepository;

  const CheckAuthStatusUsecase(this._authRepository);

  @override
  Future<Either<Failure, AuthStatusResult>> call(NoParams params) {
    return _authRepository.checkAuthState();
  }
}

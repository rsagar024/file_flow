import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignOutLocalOnlyUsecase implements Usecase<void, NoParams> {
  final AuthRepository _authRepository;

  const SignOutLocalOnlyUsecase(this._authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _authRepository.signOutLocalOnly();
  }
}

import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class VerifyOtpUsecase implements Usecase<AuthResult, VerifyOtpParams> {
  final AuthRepository _authRepository;

  const VerifyOtpUsecase(this._authRepository);

  @override
  Future<Either<Failure, AuthResult>> call(VerifyOtpParams params) {
    return _authRepository.verifyOtp(params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String otp;

  const VerifyOtpParams(this.otp);

  @override
  List<Object?> get props => [otp];
}

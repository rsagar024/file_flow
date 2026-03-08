import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResendOtpUsecase implements Usecase<String, ResendOtpParams> {
  final AuthRepository _authRepository;

  const ResendOtpUsecase(this._authRepository);

  @override
  Future<Either<Failure, String>> call(ResendOtpParams params) {
    return _authRepository.resendOtp(params.phoneNumber);
  }
}

class ResendOtpParams extends Equatable {
  final String phoneNumber;

  const ResendOtpParams(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

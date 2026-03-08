import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendOtpUsecase implements Usecase<String, SendOtpParams> {
  final AuthRepository _authRepository;

  const SendOtpUsecase(this._authRepository);

  @override
  Future<Either<Failure, String>> call(SendOtpParams params) {
    return _authRepository.sendOtp(params.phoneNumber);
  }
}

class SendOtpParams extends Equatable {
  final String phoneNumber;

  const SendOtpParams(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

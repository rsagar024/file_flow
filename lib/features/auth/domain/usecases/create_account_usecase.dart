import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateAccountUsecase implements Usecase<UserEntity, CreateAccountParams> {
  final AuthRepository _authRepository;

  const CreateAccountUsecase(this._authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(CreateAccountParams params) {
    return _authRepository.createAccount(
      UserEntity(
        uid: params.uid,
        phoneNumber: params.phoneNumber,
        displayName: params.displayName,
        username: params.username,
        email: params.email,
        photoUrl: params.photoUrl,
      ),
    );
  }
}

class CreateAccountParams extends Equatable {
  final String uid;
  final String phoneNumber;
  final String displayName;
  final String username;
  final String email;
  final String photoUrl;

  const CreateAccountParams({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    required this.username,
    required this.email,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [
    uid,
    phoneNumber,
    displayName,
    username,
    email,
    photoUrl,
  ];
}

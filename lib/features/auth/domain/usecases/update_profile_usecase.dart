import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateProfileUsecase implements Usecase<UserEntity, UpdateProfileParams> {
  final AuthRepository _authRepository;

  const UpdateProfileUsecase(this._authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return _authRepository.updateProfile(
      uid: params.uid,
      displayName: params.displayName,
      username: params.username,
      email: params.email,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String uid;
  final String? displayName;
  final String? username;
  final String? email;
  final String? photoUrl;

  const UpdateProfileParams({
    required this.uid,
    this.displayName,
    this.username,
    this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, displayName, username, email, photoUrl];
}

import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);

  Future<Either<Failure, AuthResult>> verifyOtp(String otp);

  Future<Either<Failure, String>> resendOtp(String phoneNumber);

  Future<Either<Failure, AuthStatusResult>> checkAuthState();

  Future<Either<Failure, UserEntity>> createAccount(UserEntity userEntity);

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AuthResult>> signInWithAutoVerifiedCredential(dynamic credential);
}

class AuthResult extends Equatable {
  final String uid;
  final String phoneNumber;
  final bool isNewUser;
  final UserEntity? existingUser;

  const AuthResult({required this.uid, required this.phoneNumber, required this.isNewUser, this.existingUser});

  @override
  List<Object?> get props => [uid, phoneNumber, isNewUser, existingUser];
}

class AuthStatusResult extends Equatable {
  final bool isLoggedIn;
  final bool isNewUser;
  final UserEntity? user;
  final String? uid;
  final String? phoneNumber;

  const AuthStatusResult({required this.isLoggedIn, required this.isNewUser, this.user, this.uid, this.phoneNumber});

  @override
  List<Object?> get props => throw UnimplementedError();
}

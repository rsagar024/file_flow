import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/services/device_info_service.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;
  final DeviceInfoService _deviceInfoService;

  AuthRepositoryImpl(this._authRemoteDatasource, this._deviceInfoService);

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      final verificationId = await _authRemoteDatasource.sendOtp(phoneNumber, (credential) {});
      return Right(verificationId);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyOtp(String otp) async {
    try {
      final userCredential = await _authRemoteDatasource.verifyOtp(otp);
      return await _processUserCredential(userCredential);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resendOtp(String phoneNumber) async {
    try {
      final verificationId = await _authRemoteDatasource.resendOtp(phoneNumber, (credential) {});
      return Right(verificationId);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthStatusResult>> checkAuthState() async {
    try {
      final user = _authRemoteDatasource.getCurrentFirebaseUser();

      if (user == null) {
        return const Right(AuthStatusResult(isLoggedIn: false, isNewUser: false));
      }

      final userModel = await _authRemoteDatasource.getUserFromFirestore(user.uid);

      if (userModel != null) {
        return Right(
          AuthStatusResult(
            isLoggedIn: true,
            isNewUser: false,
            user: userModel.toEntity(),
            uid: user.uid,
            phoneNumber: user.phoneNumber,
          ),
        );
      }

      return Right(AuthStatusResult(isLoggedIn: true, isNewUser: true, uid: user.uid, phoneNumber: user.phoneNumber));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createAccount(UserEntity userEntity) async {
    try {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final userModel = userEntity
          .copyWith(
            devices: [
              {deviceInfo.deviceId ?? 'unknown': deviceInfo},
            ],
          )
          .toModel();
      final result = await _authRemoteDatasource.createUserInFirestore(userModel);

      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithAutoVerifiedCredential(dynamic credential) async {
    try {
      if (credential is! PhoneAuthCredential) {
        return Left(Failure('Invalid credential'));
      }
      final userCredential = await _authRemoteDatasource.signInWithCredential(credential);
      return await _processUserCredential(userCredential);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authRemoteDatasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, AuthResult>> _processUserCredential(UserCredential userCredential) async {
    final user = userCredential.user;

    if (user == null) {
      return Left(Failure('Verification Failed'));
    }

    final existingUser = await _authRemoteDatasource.getUserFromFirestore(user.uid);

    if (existingUser != null) {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      await _authRemoteDatasource.updateDeviceInfo(user.uid, deviceInfo.toModel());

      return Right(
        AuthResult(
          uid: user.uid,
          phoneNumber: user.phoneNumber ?? '',
          isNewUser: false,
          existingUser: existingUser.toEntity(),
        ),
      );
    }

    return Right(AuthResult(uid: user.uid, phoneNumber: user.phoneNumber ?? '', isNewUser: true));
  }
}

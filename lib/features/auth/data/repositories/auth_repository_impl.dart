import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/services/device_info_service.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
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
      final verificationId = await _authRemoteDatasource.sendOtp(
        phoneNumber,
        (credential) {},
      );
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
      final verificationId = await _authRemoteDatasource.resendOtp(
        phoneNumber,
        (credential) {},
      );
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
        return const Right(
          AuthStatusResult(isLoggedIn: false, isNewUser: false),
        );
      }

      final userModel = await _authRemoteDatasource.getUserFromFirestore(
        user.uid,
      );

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

      return Right(
        AuthStatusResult(
          isLoggedIn: true,
          isNewUser: true,
          uid: user.uid,
          phoneNumber: user.phoneNumber,
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createAccount(
    UserEntity userEntity,
  ) async {
    try {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final userModel = userEntity
          .copyWith(devices: {deviceInfo.deviceId ?? 'unknown': deviceInfo})
          .toModel();
      final result = await _authRemoteDatasource.createUserInFirestore(
        userModel,
      );

      return Right(result.toEntity());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithAutoVerifiedCredential(
    dynamic credential,
  ) async {
    try {
      if (credential is! PhoneAuthCredential) {
        return Left(Failure('Invalid credential'));
      }
      final userCredential = await _authRemoteDatasource.signInWithCredential(
        credential,
      );
      return await _processUserCredential(userCredential);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final user = _authRemoteDatasource.getCurrentFirebaseUser();
      if (user != null) {
        try {
          // Best-effort, must run BEFORE firebaseAuth.signOut(): once signed out,
          // Firestore security rules (request.auth.uid == uid) would reject this write.
          final deviceInfo = await _deviceInfoService.getDeviceInfo();
          final deviceId = deviceInfo.deviceId;
          if (deviceId != null) {
            await _authRemoteDatasource.setDeviceActive(
              user.uid,
              deviceId,
              isActive: false,
            );
          }
        } catch (_) {}
      }
      await _authRemoteDatasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<DeviceEntity>> watchDevices(String uid) {
    return _authRemoteDatasource.watchUser(uid).map((userModel) {
      final devices =
          (userModel?.devices?.values ?? const <DeviceEntity>[])
              .where((d) => d.isActive == true)
              .toList()
            ..sort(
              (a, b) =>
                  (b.lastLoginAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                      .compareTo(
                        a.lastLoginAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                      ),
            );
      return devices;
    });
  }

  @override
  Stream<bool> watchCurrentDeviceActiveStatus(String uid, String deviceId) {
    return _authRemoteDatasource.watchUser(uid).map((userModel) {
      final device = userModel?.devices?[deviceId];
      return device?.isActive ?? false;
    });
  }

  @override
  Future<Either<Failure, String>> getCurrentDeviceId() async {
    try {
      final info = await _deviceInfoService.getDeviceInfo();
      return Right(info.deviceId ?? 'unknown');
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logoutDevice({
    required String uid,
    required String deviceId,
  }) async {
    try {
      await _authRemoteDatasource.setDeviceActive(
        uid,
        deviceId,
        isActive: false,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logoutAllOtherDevices({
    required String uid,
    required String currentDeviceId,
  }) async {
    try {
      await _authRemoteDatasource.deactivateOtherDevices(uid, currentDeviceId);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOutLocalOnly() async {
    try {
      await _authRemoteDatasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    String? displayName,
    String? username,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final userModel = await _authRemoteDatasource.updateUserProfile(
        uid: uid,
        displayName: displayName,
        username: username,
        email: email,
        photoUrl: photoUrl,
      );
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, AuthResult>> _processUserCredential(
    UserCredential userCredential,
  ) async {
    final user = userCredential.user;

    if (user == null) {
      return Left(Failure('Verification Failed'));
    }

    final existingUser = await _authRemoteDatasource.getUserFromFirestore(
      user.uid,
    );

    if (existingUser != null) {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      try {
        // Non-fatal: OTP verification already succeeded above, so a device-record
        // write hiccup shouldn't be reported back as an OTP verification failure.
        await _authRemoteDatasource.updateDeviceInfo(
          user.uid,
          deviceInfo.toModel(),
        );
      } catch (_) {}

      return Right(
        AuthResult(
          uid: user.uid,
          phoneNumber: user.phoneNumber ?? '',
          isNewUser: false,
          existingUser: existingUser.toEntity(),
        ),
      );
    }

    return Right(
      AuthResult(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        isNewUser: true,
      ),
    );
  }
}

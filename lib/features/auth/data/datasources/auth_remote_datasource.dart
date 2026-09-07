import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:fileflow/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRemoteDatasource {
  Future<String> sendOtp(String phoneNumber, Function(PhoneAuthCredential) onAutoVerified);

  Future<UserCredential> verifyOtp(String otp);

  Future<String> resendOtp(String phoneNumber, Function(PhoneAuthCredential) onAutoVerified);

  User? getCurrentFirebaseUser();

  Future<UserModel?> getUserFromFirestore(String uid);

  Future<UserModel> createUserInFirestore(UserModel userModel);

  Future<void> updateDeviceInfo(String uid, DeviceModel deviceModel);

  Stream<UserModel?> watchUser(String uid);

  Future<void> setDeviceActive(String uid, String deviceId, {required bool isActive});

  Future<void> deactivateOtherDevices(String uid, String excludeDeviceId);

  Future<UserModel> updateUserProfile({
    required String uid,
    String? displayName,
    String? username,
    String? email,
    String? photoUrl,
  });

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential);

  Future<void> signOut();
}

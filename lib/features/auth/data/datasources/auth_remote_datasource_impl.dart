import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:fileflow/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  String? _verificationId;
  int? _resendToken;

  AuthRemoteDatasourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<String> sendOtp(String phoneNumber, Function(PhoneAuthCredential) onAutoVerified) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e.message ?? e.code);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
    return completer.future;
  }

  @override
  Future<UserCredential> verifyOtp(String otp) async {
    if (_verificationId == null) {
      throw Failure('Otp verification failed');
    }
    final credential = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: otp);
    return await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<String> resendOtp(String phoneNumber, Function(PhoneAuthCredential) onAutoVerified) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(Failure(e.code));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
    return completer.future;
  }

  @override
  User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<UserModel> createUserInFirestore(UserModel userModel) async {
    userModel = userModel
        .copyWith(
          storageUsedBytes: 0,
          storageLimitBytes: 5368709120,
          totalFilesCount: 0,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        )
        .toModel();

    await _firestore.collection('users').doc(userModel.uid).set(userModel.toJson());
    return userModel;
  }

  @override
  Future<void> updateDeviceInfo(String uid, DeviceModel deviceModel) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return;

    final userData = doc.data()!;
    final existingDevices =
        (userData['devices'] as List<dynamic>?)
            ?.map((device) => DeviceModel.fromJson(device as Map<String, dynamic>))
            .toList() ??
        [];

    final index = existingDevices.indexWhere((device) => device.deviceId == deviceModel.deviceId);

    if (index != -1) {
      existingDevices[index] = deviceModel;
    } else {
      existingDevices.add(deviceModel);
    }

    await _firestore.collection('users').doc(uid).update({
      'devices': existingDevices.map((e) => e.toJson()).toList(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
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
  Future<String> sendOtp(
    String phoneNumber,
    Function(PhoneAuthCredential) onAutoVerified,
  ) async {
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
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<String> resendOtp(
    String phoneNumber,
    Function(PhoneAuthCredential) onAutoVerified,
  ) async {
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
    // Validate email is not already taken
    if (userModel.email != null && userModel.email!.isNotEmpty) {
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userModel.email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw Failure(StringConstants.kEmailAlreadyTaken);
      }
    }

    // Validate username (username) is not already taken
    if (userModel.username != null && userModel.username!.isNotEmpty) {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: userModel.username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Failure(StringConstants.kUsernameAlreadyTaken);
      }
    }

    userModel = userModel
        .copyWith(
          storageUsedBytes: 0,
          storageLimitBytes: 5368709120,
          totalFilesCount: 0,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        )
        .toModel();

    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toJson());
    return userModel;
  }

  @override
  Future<void> updateDeviceInfo(String uid, DeviceModel deviceModel) async {
    final deviceId = deviceModel.deviceId ?? 'unknown';
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    final rawDevices = snapshot.data()?['devices'];

    if (rawDevices is List) {
      // Legacy shape on this account — self-heal by replacing entirely with the new map shape.
      await docRef.update({
        'devices': {deviceId: deviceModel.toJson()},
      });
    } else {
      // deviceId can legitimately contain dots (e.g. Android's Build.ID), and
      // DocumentReference.update() splits dotted string keys into nested field
      // paths — so this must use FieldPath to keep deviceId as one literal segment.
      await docRef.update(<Object, dynamic>{
        FieldPath(['devices', deviceId]): deviceModel.toJson(),
      });
    }
  }

  @override
  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        // Only trust server-acknowledged data — with offline persistence on,
        // a real device can otherwise deliver a stale cached doc first.
        .where((doc) => !doc.metadata.isFromCache)
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return UserModel.fromJson(doc.data()!);
        });
  }

  @override
  Future<void> setDeviceActive(
    String uid,
    String deviceId, {
    required bool isActive,
  }) async {
    await _firestore.collection('users').doc(uid).update(<Object, dynamic>{
      FieldPath(['devices', deviceId, 'isActive']): isActive,
    });
  }

  @override
  Future<void> deactivateOtherDevices(
    String uid,
    String excludeDeviceId,
  ) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    final rawDevices = snapshot.data()?['devices'];
    if (rawDevices is! Map) return;

    final updates = <Object, dynamic>{};
    for (final key in rawDevices.keys) {
      if (key == excludeDeviceId) continue;
      updates[FieldPath(['devices', key, 'isActive'])] = false;
    }
    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String uid,
    String? displayName,
    String? username,
    String? email,
    String? photoUrl,
  }) async {
    if (username != null && username.isNotEmpty) {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      final takenByAnotherUser = usernameQuery.docs.any((doc) => doc.id != uid);
      if (takenByAnotherUser) {
        throw Failure(StringConstants.kUsernameAlreadyTaken);
      }
    }

    if (email != null && email.isNotEmpty) {
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final takenByAnotherUser = emailQuery.docs.any((doc) => doc.id != uid);
      if (takenByAnotherUser) {
        throw Failure(StringConstants.kEmailAlreadyTaken);
      }
    }

    final docRef = _firestore.collection('users').doc(uid);
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'displayName': ?displayName,
      'username': ?username,
      'email': ?email,
      'photoUrl': ?photoUrl,
    };
    await docRef.update(updates);

    final snapshot = await docRef.get();
    return UserModel.fromJson(snapshot.data()!);
  }

  @override
  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

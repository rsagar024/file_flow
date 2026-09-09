import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Seeds a `users/{uid}` document on a [FakeFirebaseFirestore] instance for
/// `AuthRemoteDatasourceImpl` tests. Only the fields a given test cares about
/// need to be passed — everything else defaults to a reasonable value.
Future<void> seedUserDoc(
  FakeFirebaseFirestore firestore,
  String uid, {
  String? email,
  String? username,
  String? displayName,
  String? photoUrl,
  String? phoneNumber,
  int storageUsedBytes = 0,
  int storageLimitBytes = 5368709120,
  Map<String, dynamic>? devices,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return firestore.collection('users').doc(uid).set({
    'uid': uid,
    'email': email,
    'username': username,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'storageUsedBytes': storageUsedBytes,
    'storageLimitBytes': storageLimitBytes,
    'totalFilesCount': 0,
    'createdAt': (createdAt ?? DateTime.utc(2024, 1, 1)).toIso8601String(),
    'updatedAt': (updatedAt ?? DateTime.utc(2024, 1, 1)).toIso8601String(),
    'devices': devices,
  });
}

/// Builds a single device map entry as stored under `users/{uid}.devices`.
Map<String, dynamic> deviceJson({
  String? deviceId,
  String? deviceName,
  String? deviceModel,
  String? platform,
  String? appVersion,
  String? fcmToken,
  bool isActive = true,
  DateTime? lastLoginAt,
}) {
  return {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'deviceModel': deviceModel,
    'platform': platform,
    'appVersion': appVersion,
    'fcmToken': fcmToken,
    'isActive': isActive,
    'lastLoginAt': (lastLoginAt ?? DateTime.utc(2024, 1, 1)).toIso8601String(),
  };
}

Future<DocumentSnapshot<Map<String, dynamic>>> readUserDoc(
  FakeFirebaseFirestore firestore,
  String uid,
) {
  return firestore.collection('users').doc(uid).get();
}

import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    super.storageUsedBytes,
    super.storageLimitBytes,
    super.totalFilesCount,
    super.createdAt,
    super.updatedAt,
    super.devices,
    super.isNewUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      storageUsedBytes: json['storageUsedBytes'] as int?,
      storageLimitBytes: json['storageLimitBytes'] as int?,
      totalFilesCount: json['totalFilesCount'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      devices: (json['devices'] as List<dynamic>?)
          ?.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'storageUsedBytes': storageUsedBytes,
      'storageLimitBytes': storageLimitBytes,
      'totalFilesCount': totalFilesCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'devices': devices?.map((e) => (e as DeviceModel).toJson()).toList(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      storageUsedBytes: storageUsedBytes,
      storageLimitBytes: storageLimitBytes,
      totalFilesCount: totalFilesCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      devices: devices?.map((e) => (e as DeviceModel).toEntity()).toList(),
      isNewUser: isNewUser,
    );
  }
}

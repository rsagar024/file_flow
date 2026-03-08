import 'package:equatable/equatable.dart';
import 'package:fileflow/features/auth/data/models/user_model.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';

class UserEntity extends Equatable {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final int? storageUsedBytes;
  final int? storageLimitBytes;
  final int? totalFilesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<DeviceEntity>? devices;
  final bool isNewUser;

  const UserEntity({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.storageUsedBytes,
    this.storageLimitBytes,
    this.totalFilesCount,
    this.createdAt,
    this.updatedAt,
    this.devices,
    this.isNewUser = false,
  });

  double get storageUsedPercentage {
    if (storageLimitBytes == null || storageLimitBytes == 0 || storageUsedBytes == null) {
      return 0.0;
    }
    return (storageUsedBytes! / storageLimitBytes!) * 100;
  }

  String get storageUsedFormatted {
    final bytes = storageUsedBytes ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get storageLimitFormatted {
    final bytes = storageLimitBytes ?? 0;
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    storageUsedBytes,
    storageLimitBytes,
    totalFilesCount,
    createdAt,
    updatedAt,
    devices,
    isNewUser,
  ];

  UserEntity copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    int? storageUsedBytes,
    int? storageLimitBytes,
    int? totalFilesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DeviceEntity>? devices,
    bool? isNewUser,
  }) {
    return UserEntity(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
      storageLimitBytes: storageLimitBytes ?? this.storageLimitBytes,
      totalFilesCount: totalFilesCount ?? this.totalFilesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      devices: devices ?? this.devices,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  UserModel toModel() {
    return UserModel(
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
      devices: devices?.map((e) => e.toModel()).toList(),
      isNewUser: isNewUser,
    );
  }
}

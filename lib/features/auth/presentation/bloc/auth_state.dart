part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final AuthAppStatus status;
  final String? errorMessage;
  final String? phoneNumber;
  final String? verificationId;
  final UserEntity? user;
  final String? uid;
  final bool isNewUser;
  final int resendSeconds;
  final bool canResend;
  final String? imageUrl;

  const AuthState({
    this.status = AuthAppStatus.initial,
    this.errorMessage,
    this.phoneNumber,
    this.verificationId,
    this.user,
    this.uid,
    this.isNewUser = false,
    this.resendSeconds = 45,
    this.canResend = false,
    this.imageUrl,
  });

  AuthState copyWith({
    AuthAppStatus? status,
    String? errorMessage,
    String? phoneNumber,
    String? verificationId,
    UserEntity? user,
    String? uid,
    bool? isNewUser,
    int? resendSeconds,
    bool? canResend,
    String? imageUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      uid: uid ?? this.uid,
      isNewUser: isNewUser ?? this.isNewUser,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    phoneNumber,
    verificationId,
    user,
    uid,
    isNewUser,
    resendSeconds,
    canResend,
    imageUrl,
  ];
}

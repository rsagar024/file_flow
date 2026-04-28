part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final AuthAppState state;
  final String? errorMessage;
  final String? phoneNumber;
  final String? verificationId;
  final UserEntity? user;
  final String? uid;
  final bool isNewUser;
  final int resendSeconds;
  final bool canResend;

  const AuthState({
    this.state = AuthAppState.initial,
    this.errorMessage,
    this.phoneNumber,
    this.verificationId,
    this.user,
    this.uid,
    this.isNewUser = false,
    this.resendSeconds = 45,
    this.canResend = false,
  });

  AuthState copyWith({
    AuthAppState? state,
    String? errorMessage,
    String? phoneNumber,
    String? verificationId,
    UserEntity? user,
    String? uid,
    bool? isNewUser,
    int? resendSeconds,
    bool? canResend,
  }) {
    return AuthState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      uid: uid ?? this.uid,
      isNewUser: isNewUser ?? this.isNewUser,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
    );
  }

  @override
  List<Object?> get props => [
    state,
    errorMessage,
    phoneNumber,
    verificationId,
    user,
    uid,
    isNewUser,
    resendSeconds,
    canResend,
  ];
}

part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthOtpSentSuccess extends AuthState {
  final String phoneNumber;
  final String verificationId;

  const AuthOtpSentSuccess({required this.phoneNumber, required this.verificationId});

  @override
  List<Object> get props => [phoneNumber, verificationId];
}

final class AuthOtpResentSuccess extends AuthState {
  final String phoneNumber;

  const AuthOtpResentSuccess({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthNewUserDetected extends AuthState {
  final String uid;
  final String phoneNumber;

  const AuthNewUserDetected({required this.uid, required this.phoneNumber});

  @override
  List<Object> get props => [uid, phoneNumber];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object> get props => [message];
}

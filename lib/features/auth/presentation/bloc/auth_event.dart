part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckStatusEvent extends AuthEvent {}

final class OtpSendEvent extends AuthEvent {
  final String phoneNumber;

  const OtpSendEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

final class OtpTimerTickEvent extends AuthEvent {}

final class OtpVerifyEvent extends AuthEvent {
  final String otp;

  const OtpVerifyEvent({required this.otp});

  @override
  List<Object?> get props => [otp];
}

final class OtpResendEvent extends AuthEvent {
  final String phoneNumber;

  const OtpResendEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

final class UpdateProfileImageEvent extends AuthEvent {
  final String imagePath;

  const UpdateProfileImageEvent({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

final class CreateAccountEvent extends AuthEvent {
  final String phoneNumber;
  final String displayName;
  final String username;
  final String email;

  const CreateAccountEvent({
    required this.phoneNumber,
    required this.displayName,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [phoneNumber, displayName, username, email];
}

final class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

final class _RemoteDeviceDeactivatedEvent extends AuthEvent {
  const _RemoteDeviceDeactivatedEvent();
}

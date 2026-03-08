import 'dart:async';

import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUsecase _sendOtpUsecase;
  final VerifyOtpUsecase _verifyOtpUsecase;
  final ResendOtpUsecase _resendOtpUsecase;
  final CheckAuthStatusUsecase _checkAuthStatusUsecase;
  final CreateAccountUsecase _createAccountUsecase;
  final SignOutUsecase _signOutUsecase;

  AuthBloc(
    this._sendOtpUsecase,
    this._verifyOtpUsecase,
    this._resendOtpUsecase,
    this._checkAuthStatusUsecase,
    this._createAccountUsecase,
    this._signOutUsecase,
  ) : super(const AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<OtpSendEvent>(_onSendOtp);
    on<OtpVerifyEvent>(_onVerifyOtp);
    on<OtpResendEvent>(_onResendOtp);
    on<CreateAccountEvent>(_onCreateAccount);
    on<SignOutEvent>(_onSignOut);
  }

  FutureOr<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _checkAuthStatusUsecase(const NoParams());
    result.fold((failure) => emit(const AuthUnauthenticated()), (authStatus) {
      if (!authStatus.isLoggedIn) {
        emit(const AuthUnauthenticated());
      } else if (authStatus.isNewUser) {
        emit(AuthNewUserDetected(uid: authStatus.uid ?? '', phoneNumber: authStatus.phoneNumber ?? ''));
      } else {
        emit(AuthAuthenticated(user: authStatus.user!));
      }
    });
  }

  FutureOr<void> _onSendOtp(OtpSendEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _sendOtpUsecase(SendOtpParams(event.phoneNumber));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (verificationId) => emit(AuthOtpSentSuccess(phoneNumber: event.phoneNumber, verificationId: verificationId)),
    );
  }

  FutureOr<void> _onVerifyOtp(OtpVerifyEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _verifyOtpUsecase(VerifyOtpParams(event.otp));
    result.fold((failure) => emit(AuthFailureState(failure.message)), (authResult) {
      if (authResult.isNewUser) {
        emit(AuthNewUserDetected(uid: authResult.uid, phoneNumber: authResult.phoneNumber));
      } else {
        emit(AuthAuthenticated(user: authResult.existingUser!));
      }
    });
  }

  FutureOr<void> _onResendOtp(OtpResendEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _resendOtpUsecase(ResendOtpParams(event.phoneNumber));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(AuthOtpResentSuccess(phoneNumber: event.phoneNumber)),
    );
  }

  FutureOr<void> _onCreateAccount(CreateAccountEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _createAccountUsecase(
      CreateAccountParams(
        uid: event.uid,
        phoneNumber: event.phoneNumber,
        displayName: event.displayName,
        email: event.email,
        photoUrl: event.photoUrl ?? '',
      ),
    );
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) => emit(AuthAuthenticated(user: user)));
  }

  FutureOr<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signOutUsecase(const NoParams());
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) => emit(const AuthUnauthenticated()));
  }
}

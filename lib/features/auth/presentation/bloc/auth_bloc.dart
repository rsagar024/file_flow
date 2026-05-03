import 'dart:async';

import 'package:fileflow/core/enums/app_state/app_state.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter/cupertino.dart';
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

  Timer? _timer;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  AuthBloc(
    this._sendOtpUsecase,
    this._verifyOtpUsecase,
    this._resendOtpUsecase,
    this._checkAuthStatusUsecase,
    this._createAccountUsecase,
    this._signOutUsecase,
  ) : super(const AuthState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<OtpSendEvent>(_onSendOtp);
    on<OtpTimerTickEvent>(_onStartTimer);
    on<OtpVerifyEvent>(_onVerifyOtp);
    on<OtpResendEvent>(_onResendOtp);
    on<CreateAccountEvent>(_onCreateAccount);
    on<SignOutEvent>(_onSignOut);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
  }

  FutureOr<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(state: AuthAppState.loading));

    final result = await _checkAuthStatusUsecase(const NoParams());

    result.fold((failure) => emit(state.copyWith(state: AuthAppState.unAuthenticated, errorMessage: failure.message)), (
      authStatus,
    ) {
      if (!authStatus.isLoggedIn) {
        emit(state.copyWith(state: AuthAppState.unAuthenticated));
      } else if (authStatus.isNewUser) {
        phoneController.text = authStatus.phoneNumber ?? '';
        emit(
          state.copyWith(
            state: AuthAppState.newUserDetected,
            uid: authStatus.uid,
            phoneNumber: authStatus.phoneNumber,
            isNewUser: true,
          ),
        );
      } else {
        emit(state.copyWith(state: AuthAppState.authenticated, user: authStatus.user));
      }
    });
  }

  FutureOr<void> _onSendOtp(OtpSendEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(state: AuthAppState.loading));

    final result = await _sendOtpUsecase(SendOtpParams(event.phoneNumber));

    result.fold((failure) => emit(state.copyWith(state: AuthAppState.failure, errorMessage: failure.message)), (
      verificationId,
    ) {
      _startTimer();
      emit(state.copyWith(state: AuthAppState.otpSent, phoneNumber: event.phoneNumber, verificationId: verificationId));
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(OtpTimerTickEvent());
    });
  }

  FutureOr<void> _onStartTimer(OtpTimerTickEvent event, Emitter<AuthState> emit) {
    if (state.resendSeconds == 0) {
      _timer?.cancel();
      emit(state.copyWith(canResend: true));
    } else {
      emit(state.copyWith(resendSeconds: state.resendSeconds - 1, canResend: false));
    }
  }

  FutureOr<void> _onVerifyOtp(OtpVerifyEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(state: AuthAppState.loading));

    final result = await _verifyOtpUsecase(VerifyOtpParams(event.otp));

    result.fold((failure) => emit(state.copyWith(state: AuthAppState.failure, errorMessage: failure.message)), (
      authResult,
    ) {
      _timer?.cancel();
      if (authResult.isNewUser) {
        emit(
          state.copyWith(
            state: AuthAppState.newUserDetected,
            uid: authResult.uid,
            phoneNumber: authResult.phoneNumber,
            isNewUser: true,
          ),
        );
      } else {
        emit(state.copyWith(state: AuthAppState.authenticated, user: authResult.existingUser));
      }
    });
  }

  FutureOr<void> _onResendOtp(OtpResendEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(state: AuthAppState.loading, resendSeconds: 45));

    final result = await _resendOtpUsecase(ResendOtpParams(event.phoneNumber));

    result.fold((failure) => emit(state.copyWith(state: AuthAppState.failure, errorMessage: failure.message)), (_) {
      _startTimer();
      emit(state.copyWith(state: AuthAppState.otpResent, phoneNumber: event.phoneNumber));
    });
  }

  FutureOr<void> _onCreateAccount(CreateAccountEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(state: AuthAppState.loading));

    final result = await _createAccountUsecase(
      CreateAccountParams(
        uid: state.uid ?? '',
        phoneNumber: event.phoneNumber,
        displayName: event.displayName,
        email: event.email,
        photoUrl: state.imageUrl ?? '',
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(state: AuthAppState.failure, errorMessage: failure.message)),
      (user) => emit(state.copyWith(state: AuthAppState.authenticated, user: user)),
    );
  }

  FutureOr<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(state: AuthAppState.loading));

    final result = await _signOutUsecase(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(state: AuthAppState.failure, errorMessage: failure.message)),
      (_) => emit(const AuthState(state: AuthAppState.unAuthenticated)),
    );
  }

  FutureOr<void> _onUpdateProfileImage(UpdateProfileImageEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(imageUrl: event.imagePath));
  }

  @override
  Future<void> close() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _timer?.cancel();
    return super.close();
  }
}

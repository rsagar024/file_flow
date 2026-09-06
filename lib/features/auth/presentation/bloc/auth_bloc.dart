import 'dart:async';

import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/get_current_device_id_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_local_only_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_current_device_active_status_usecase.dart';
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
  final GetCurrentDeviceIdUsecase _getCurrentDeviceIdUsecase;
  final WatchCurrentDeviceActiveStatusUsecase
  _watchCurrentDeviceActiveStatusUsecase;
  final SignOutLocalOnlyUsecase _signOutLocalOnlyUsecase;

  Timer? _timer;
  StreamSubscription<bool>? _deviceActiveSubscription;

  AuthBloc(
    this._sendOtpUsecase,
    this._verifyOtpUsecase,
    this._resendOtpUsecase,
    this._checkAuthStatusUsecase,
    this._createAccountUsecase,
    this._signOutUsecase,
    this._getCurrentDeviceIdUsecase,
    this._watchCurrentDeviceActiveStatusUsecase,
    this._signOutLocalOnlyUsecase,
  ) : super(const AuthState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<OtpSendEvent>(_onSendOtp);
    on<OtpTimerTickEvent>(_onStartTimer);
    on<OtpVerifyEvent>(_onVerifyOtp);
    on<OtpResendEvent>(_onResendOtp);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
    on<CreateAccountEvent>(_onCreateAccount);
    on<SignOutEvent>(_onSignOut);
    on<_RemoteDeviceDeactivatedEvent>(_onRemoteDeviceDeactivated);
  }

  Future<void> _startDeviceEnforcement(String uid, {String? deviceId}) async {
    await _deviceActiveSubscription?.cancel();
    final id =
        deviceId ??
        (await _getCurrentDeviceIdUsecase(
          const NoParams(),
        )).getOrElse((_) => '');
    if (id.isEmpty) return;
    _deviceActiveSubscription =
        _watchCurrentDeviceActiveStatusUsecase(
          WatchCurrentDeviceActiveStatusParams(uid: uid, deviceId: id),
        ).listen((isActive) {
          if (!isActive) add(const _RemoteDeviceDeactivatedEvent());
        });
  }

  FutureOr<void> _onRemoteDeviceDeactivated(
    _RemoteDeviceDeactivatedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _deviceActiveSubscription?.cancel();
    _deviceActiveSubscription = null;
    await _signOutLocalOnlyUsecase(const NoParams());
    emit(const AuthState(status: AuthAppStatus.unAuthenticated));
  }

  FutureOr<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthAppStatus.loading));

    final result = await _checkAuthStatusUsecase(const NoParams());

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: AuthAppStatus.unAuthenticated,
          errorMessage: failure.message,
        ),
      ),
      (authStatus) async {
        if (!authStatus.isLoggedIn) {
          emit(state.copyWith(status: AuthAppStatus.unAuthenticated));
          return;
        }
        if (authStatus.isNewUser) {
          emit(
            state.copyWith(
              status: AuthAppStatus.newUserDetected,
              uid: authStatus.uid,
              phoneNumber: authStatus.phoneNumber,
              isNewUser: true,
            ),
          );
          return;
        }

        final deviceIdResult = await _getCurrentDeviceIdUsecase(
          const NoParams(),
        );
        final deviceId = deviceIdResult.getOrElse((_) => '');
        final userDevices = authStatus.user?.devices;
        final ownDevice = deviceId.isEmpty ? null : userDevices?[deviceId];

        if (ownDevice != null && ownDevice.isActive == false) {
          await _signOutLocalOnlyUsecase(const NoParams());
          emit(const AuthState(status: AuthAppStatus.unAuthenticated));
          return;
        }

        emit(
          state.copyWith(
            status: AuthAppStatus.authenticated,
            user: authStatus.user,
          ),
        );
        _startDeviceEnforcement(
          authStatus.uid ?? authStatus.user?.uid ?? '',
          deviceId: deviceId.isEmpty ? null : deviceId,
        );
      },
    );
  }

  FutureOr<void> _onSendOtp(OtpSendEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthAppStatus.loading));

    final result = await _sendOtpUsecase(SendOtpParams(event.phoneNumber));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthAppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (verificationId) {
        _startTimer();
        emit(
          state.copyWith(
            status: AuthAppStatus.otpSent,
            phoneNumber: event.phoneNumber,
            verificationId: verificationId,
          ),
        );
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(OtpTimerTickEvent());
    });
  }

  FutureOr<void> _onStartTimer(
    OtpTimerTickEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state.resendSeconds == 0) {
      _timer?.cancel();
      emit(state.copyWith(canResend: true));
    } else {
      emit(
        state.copyWith(
          resendSeconds: state.resendSeconds - 1,
          canResend: false,
        ),
      );
    }
  }

  FutureOr<void> _onVerifyOtp(
    OtpVerifyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthAppStatus.loading));

    final result = await _verifyOtpUsecase(VerifyOtpParams(event.otp));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthAppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (authResult) {
        _timer?.cancel();
        if (authResult.isNewUser) {
          emit(
            state.copyWith(
              status: AuthAppStatus.newUserDetected,
              uid: authResult.uid,
              phoneNumber: authResult.phoneNumber,
              isNewUser: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthAppStatus.authenticated,
              user: authResult.existingUser,
            ),
          );
          _startDeviceEnforcement(authResult.uid);
        }
      },
    );
  }

  FutureOr<void> _onResendOtp(
    OtpResendEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthAppStatus.loading, resendSeconds: 45));

    final result = await _resendOtpUsecase(ResendOtpParams(event.phoneNumber));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthAppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        _startTimer();
        emit(
          state.copyWith(
            status: AuthAppStatus.otpResent,
            phoneNumber: event.phoneNumber,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(imageUrl: event.imagePath));
  }

  FutureOr<void> _onCreateAccount(
    CreateAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthAppStatus.loading));

    final result = await _createAccountUsecase(
      CreateAccountParams(
        uid: state.uid ?? '',
        phoneNumber: event.phoneNumber,
        displayName: event.displayName,
        username: event.username,
        email: event.email,
        photoUrl: state.imageUrl ?? '',
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthAppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) {
        emit(state.copyWith(status: AuthAppStatus.authenticated, user: user));
        _startDeviceEnforcement(state.uid ?? user.uid ?? '');
      },
    );
  }

  FutureOr<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthAppStatus.loading));
    await _deviceActiveSubscription?.cancel();
    _deviceActiveSubscription = null;

    final result = await _signOutUsecase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthAppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(const AuthState(status: AuthAppStatus.unAuthenticated)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _deviceActiveSubscription?.cancel();
    return super.close();
  }
}

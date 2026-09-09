import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_current_device_active_status_usecase.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSendOtpUsecase sendOtpUsecase;
  late MockVerifyOtpUsecase verifyOtpUsecase;
  late MockResendOtpUsecase resendOtpUsecase;
  late MockCheckAuthStatusUsecase checkAuthStatusUsecase;
  late MockCreateAccountUsecase createAccountUsecase;
  late MockSignOutUsecase signOutUsecase;
  late MockGetCurrentDeviceIdUsecase getCurrentDeviceIdUsecase;
  late MockWatchCurrentDeviceActiveStatusUsecase
  watchCurrentDeviceActiveStatusUsecase;
  late MockSignOutLocalOnlyUsecase signOutLocalOnlyUsecase;
  late MockUpdateProfileUsecase updateProfileUsecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    sendOtpUsecase = MockSendOtpUsecase();
    verifyOtpUsecase = MockVerifyOtpUsecase();
    resendOtpUsecase = MockResendOtpUsecase();
    checkAuthStatusUsecase = MockCheckAuthStatusUsecase();
    createAccountUsecase = MockCreateAccountUsecase();
    signOutUsecase = MockSignOutUsecase();
    getCurrentDeviceIdUsecase = MockGetCurrentDeviceIdUsecase();
    watchCurrentDeviceActiveStatusUsecase =
        MockWatchCurrentDeviceActiveStatusUsecase();
    signOutLocalOnlyUsecase = MockSignOutLocalOnlyUsecase();
    updateProfileUsecase = MockUpdateProfileUsecase();

    // Harmless defaults for the fire-and-forget device-enforcement chain so
    // that tests which don't care about it can ignore it safely.
    when(
      () => getCurrentDeviceIdUsecase(any()),
    ).thenAnswer((_) async => const Right('device-1'));
    when(
      () => watchCurrentDeviceActiveStatusUsecase(any()),
    ).thenAnswer((_) => const Stream<bool>.empty());
    when(
      () => signOutLocalOnlyUsecase(any()),
    ).thenAnswer((_) async => const Right(null));
  });

  AuthBloc buildBloc() {
    return AuthBloc(
      sendOtpUsecase,
      verifyOtpUsecase,
      resendOtpUsecase,
      checkAuthStatusUsecase,
      createAccountUsecase,
      signOutUsecase,
      getCurrentDeviceIdUsecase,
      watchCurrentDeviceActiveStatusUsecase,
      signOutLocalOnlyUsecase,
      updateProfileUsecase,
    );
  }

  group('AuthCheckStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, unAuthenticated w/ error] when the usecase fails',
      build: () {
        when(
          () => checkAuthStatusUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('network error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.unAuthenticated,
          errorMessage: 'network error',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unAuthenticated] when not logged in',
      build: () {
        const authStatusResult = AuthStatusResult(
          isLoggedIn: false,
          isNewUser: false,
        );
        when(
          () => checkAuthStatusUsecase(any()),
        ).thenAnswer((_) async => const Right(authStatusResult));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(status: AuthAppStatus.unAuthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, newUserDetected w/ uid+phone] for a new user',
      build: () {
        const authStatusResult = AuthStatusResult(
          isLoggedIn: true,
          isNewUser: true,
          uid: 'uid-new',
          phoneNumber: '+10000000001',
        );
        when(
          () => checkAuthStatusUsecase(any()),
        ).thenAnswer((_) async => const Right(authStatusResult));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.newUserDetected,
          uid: 'uid-new',
          phoneNumber: '+10000000001',
          isNewUser: true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'existing user whose OWN device is inactive is signed out locally and '
      'ends up unAuthenticated (fresh default state)',
      build: () {
        const user = UserEntity(
          uid: 'uid-inactive',
          devices: {
            'device-1': DeviceEntity(deviceId: 'device-1', isActive: false),
          },
        );
        const authStatusResult = AuthStatusResult(
          isLoggedIn: true,
          isNewUser: false,
          uid: 'uid-inactive',
          user: user,
        );
        when(
          () => checkAuthStatusUsecase(any()),
        ).thenAnswer((_) async => const Right(authStatusResult));
        // getCurrentDeviceIdUsecase default stub returns 'device-1', which
        // matches the (inactive) device in the map above.
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(status: AuthAppStatus.unAuthenticated),
      ],
      verify: (_) {
        verify(() => signOutLocalOnlyUsecase(const NoParams())).called(1);
        verify(() => getCurrentDeviceIdUsecase(const NoParams())).called(1);
        verifyNever(() => watchCurrentDeviceActiveStatusUsecase(any()));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'existing user with an ACTIVE own device becomes authenticated and '
      'starts device enforcement',
      build: () {
        const user = UserEntity(
          uid: 'uid-active',
          devices: {
            'device-1': DeviceEntity(deviceId: 'device-1', isActive: true),
          },
        );
        const authStatusResult = AuthStatusResult(
          isLoggedIn: true,
          isNewUser: false,
          uid: 'uid-active',
          user: user,
        );
        when(
          () => checkAuthStatusUsecase(any()),
        ).thenAnswer((_) async => const Right(authStatusResult));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.authenticated,
          user: UserEntity(
            uid: 'uid-active',
            devices: {
              'device-1': DeviceEntity(deviceId: 'device-1', isActive: true),
            },
          ),
        ),
      ],
      verify: (_) {
        // deviceId was already fetched once in _onCheckStatus and handed
        // straight to _startDeviceEnforcement, so it is NOT re-fetched.
        verify(() => getCurrentDeviceIdUsecase(const NoParams())).called(1);
        verify(
          () => watchCurrentDeviceActiveStatusUsecase(
            const WatchCurrentDeviceActiveStatusParams(
              uid: 'uid-active',
              deviceId: 'device-1',
            ),
          ),
        ).called(1);
        verifyNever(() => signOutLocalOnlyUsecase(any()));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'existing user whose current device is NOT FOUND in their devices map '
      'is treated like an active device: authenticated + enforcement started',
      build: () {
        const user = UserEntity(
          uid: 'uid-notfound',
          devices: {
            'other-device': DeviceEntity(
              deviceId: 'other-device',
              isActive: false,
            ),
          },
        );
        const authStatusResult = AuthStatusResult(
          isLoggedIn: true,
          isNewUser: false,
          uid: 'uid-notfound',
          user: user,
        );
        when(
          () => checkAuthStatusUsecase(any()),
        ).thenAnswer((_) async => const Right(authStatusResult));
        when(
          () => getCurrentDeviceIdUsecase(any()),
        ).thenAnswer((_) async => const Right('device-2'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.authenticated,
          user: UserEntity(
            uid: 'uid-notfound',
            devices: {
              'other-device': DeviceEntity(
                deviceId: 'other-device',
                isActive: false,
              ),
            },
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => watchCurrentDeviceActiveStatusUsecase(
            const WatchCurrentDeviceActiveStatusParams(
              uid: 'uid-notfound',
              deviceId: 'device-2',
            ),
          ),
        ).called(1);
        verifyNever(() => signOutLocalOnlyUsecase(any()));
      },
    );
  });

  group('OtpSendEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, otpSent] carrying phone number + verification id',
      build: () {
        when(
          () => sendOtpUsecase(any()),
        ).thenAnswer((_) async => const Right('verification-id-1'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const OtpSendEvent(phoneNumber: '+10000000000')),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.otpSent,
          phoneNumber: '+10000000000',
          verificationId: 'verification-id-1',
        ),
      ],
      verify: (_) {
        verify(
          () => sendOtpUsecase(const SendOtpParams('+10000000000')),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when sending the otp fails',
      build: () {
        when(
          () => sendOtpUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('send otp failed')));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const OtpSendEvent(phoneNumber: '+10000000000')),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.failure,
          errorMessage: 'send otp failed',
        ),
      ],
    );
  });

  group('OtpTimerTickEvent (resend countdown reducer)', () {
    // OtpTimerTickEvent is a public class (not the leading-underscore private
    // event), so it can be constructed and added directly from the test
    // without needing to wait on a real Timer.
    blocTest<AuthBloc, AuthState>(
      'decrements resendSeconds and keeps canResend false while seconds > 0',
      build: buildBloc,
      seed: () => const AuthState(resendSeconds: 5, canResend: false),
      act: (bloc) => bloc.add(OtpTimerTickEvent()),
      expect: () => [const AuthState(resendSeconds: 4, canResend: false)],
    );

    blocTest<AuthBloc, AuthState>(
      'consecutive ticks keep decrementing',
      build: buildBloc,
      seed: () => const AuthState(resendSeconds: 2, canResend: false),
      act: (bloc) {
        bloc.add(OtpTimerTickEvent());
        bloc.add(OtpTimerTickEvent());
      },
      expect: () => [
        const AuthState(resendSeconds: 1, canResend: false),
        const AuthState(resendSeconds: 0, canResend: false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'once resendSeconds hits 0, a further tick flips canResend to true and '
      'leaves resendSeconds unchanged',
      build: buildBloc,
      seed: () => const AuthState(resendSeconds: 0, canResend: false),
      act: (bloc) => bloc.add(OtpTimerTickEvent()),
      expect: () => [const AuthState(resendSeconds: 0, canResend: true)],
    );
  });

  group('OtpVerifyEvent', () {
    blocTest<AuthBloc, AuthState>(
      'success + new user emits [loading, newUserDetected]',
      build: () {
        const authResult = AuthResult(
          uid: 'uid-verify-new',
          phoneNumber: '+10000000002',
          isNewUser: true,
        );
        when(
          () => verifyOtpUsecase(any()),
        ).thenAnswer((_) async => const Right(authResult));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const OtpVerifyEvent(otp: '123456')),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.newUserDetected,
          uid: 'uid-verify-new',
          phoneNumber: '+10000000002',
          isNewUser: true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'success + existing user emits [loading, authenticated] and starts '
      'device enforcement',
      build: () {
        const existingUser = UserEntity(uid: 'uid-verify-existing');
        const authResult = AuthResult(
          uid: 'uid-verify-existing',
          phoneNumber: '+10000000003',
          isNewUser: false,
          existingUser: existingUser,
        );
        when(
          () => verifyOtpUsecase(any()),
        ).thenAnswer((_) async => const Right(authResult));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const OtpVerifyEvent(otp: '123456')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.authenticated,
          user: UserEntity(uid: 'uid-verify-existing'),
        ),
      ],
      verify: (_) {
        verify(
          () => getCurrentDeviceIdUsecase(const NoParams()),
        ).called(1);
        verify(
          () => watchCurrentDeviceActiveStatusUsecase(
            const WatchCurrentDeviceActiveStatusParams(
              uid: 'uid-verify-existing',
              deviceId: 'device-1',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'failure emits [loading, failure]',
      build: () {
        when(
          () => verifyOtpUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('invalid otp')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const OtpVerifyEvent(otp: '000000')),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.failure,
          errorMessage: 'invalid otp',
        ),
      ],
    );
  });

  group('OtpResendEvent', () {
    blocTest<AuthBloc, AuthState>(
      'resets the countdown to 45 immediately, then otpResent on success',
      build: () {
        when(
          () => resendOtpUsecase(any()),
        ).thenAnswer((_) async => const Right('verification-id-2'));
        return buildBloc();
      },
      seed: () => const AuthState(resendSeconds: 10, canResend: true),
      act: (bloc) =>
          bloc.add(const OtpResendEvent(phoneNumber: '+10000000000')),
      expect: () => [
        const AuthState(
          status: AuthAppStatus.loading,
          resendSeconds: 45,
          canResend: true,
        ),
        const AuthState(
          status: AuthAppStatus.otpResent,
          phoneNumber: '+10000000000',
          resendSeconds: 45,
          canResend: true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'failure still resets resendSeconds to 45 but emits failure status',
      build: () {
        when(
          () => resendOtpUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('resend failed')));
        return buildBloc();
      },
      seed: () => const AuthState(resendSeconds: 10, canResend: true),
      act: (bloc) =>
          bloc.add(const OtpResendEvent(phoneNumber: '+10000000000')),
      expect: () => [
        const AuthState(
          status: AuthAppStatus.loading,
          resendSeconds: 45,
          canResend: true,
        ),
        const AuthState(
          status: AuthAppStatus.failure,
          errorMessage: 'resend failed',
          resendSeconds: 45,
          canResend: true,
        ),
      ],
    );
  });

  group('UpdateProfileImageEvent', () {
    blocTest<AuthBloc, AuthState>(
      'only mutates imageUrl and calls no usecases',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const UpdateProfileImageEvent(imagePath: '/tmp/pic.png')),
      expect: () => [const AuthState(imageUrl: '/tmp/pic.png')],
      verify: (_) {
        verifyNever(() => sendOtpUsecase(any()));
        verifyNever(() => verifyOtpUsecase(any()));
        verifyNever(() => resendOtpUsecase(any()));
        verifyNever(() => checkAuthStatusUsecase(any()));
        verifyNever(() => createAccountUsecase(any()));
        verifyNever(() => updateProfileUsecase(any()));
        verifyNever(() => signOutUsecase(any()));
      },
    );
  });

  group('CreateAccountEvent', () {
    blocTest<AuthBloc, AuthState>(
      'builds params from event fields PLUS state.uid/state.imageUrl, then '
      'authenticates and starts device enforcement',
      build: () {
        const createdUser = UserEntity(uid: 'uid-from-state');
        when(
          () => createAccountUsecase(any()),
        ).thenAnswer((_) async => const Right(createdUser));
        return buildBloc();
      },
      seed: () => const AuthState(
        uid: 'uid-from-state',
        imageUrl: 'https://img.example.com/1.png',
      ),
      act: (bloc) => bloc.add(
        const CreateAccountEvent(
          phoneNumber: '+10000000000',
          displayName: 'Jane Doe',
          username: 'janedoe',
          email: 'jane@example.com',
        ),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const AuthState(
          status: AuthAppStatus.loading,
          uid: 'uid-from-state',
          imageUrl: 'https://img.example.com/1.png',
        ),
        const AuthState(
          status: AuthAppStatus.authenticated,
          uid: 'uid-from-state',
          imageUrl: 'https://img.example.com/1.png',
          user: UserEntity(uid: 'uid-from-state'),
        ),
      ],
      verify: (_) {
        verify(
          () => createAccountUsecase(
            const CreateAccountParams(
              uid: 'uid-from-state',
              phoneNumber: '+10000000000',
              displayName: 'Jane Doe',
              username: 'janedoe',
              email: 'jane@example.com',
              photoUrl: 'https://img.example.com/1.png',
            ),
          ),
        ).called(1);
        verify(
          () => watchCurrentDeviceActiveStatusUsecase(
            const WatchCurrentDeviceActiveStatusParams(
              uid: 'uid-from-state',
              deviceId: 'device-1',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'failure emits [loading, failure]',
      build: () {
        when(
          () => createAccountUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('create account failed')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const CreateAccountEvent(
          phoneNumber: '+10000000000',
          displayName: 'Jane Doe',
          username: 'janedoe',
          email: 'jane@example.com',
        ),
      ),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.failure,
          errorMessage: 'create account failed',
        ),
      ],
    );
  });

  group('UpdateProfileDetailsEvent', () {
    blocTest<AuthBloc, AuthState>(
      'uses state.user?.uid (NOT state.uid) to build params, then '
      'profileUpdating -> profileUpdateSuccess',
      build: () {
        const updatedUser = UserEntity(
          uid: 'uid-from-user',
          displayName: 'New Name',
        );
        when(
          () => updateProfileUsecase(any()),
        ).thenAnswer((_) async => const Right(updatedUser));
        return buildBloc();
      },
      // Deliberately give state.uid a DIFFERENT value than state.user.uid to
      // prove the handler reads the uid from state.user, not state.uid.
      seed: () => const AuthState(
        uid: 'uid-that-should-be-ignored',
        user: UserEntity(uid: 'uid-from-user', displayName: 'Old Name'),
      ),
      act: (bloc) => bloc.add(
        const UpdateProfileDetailsEvent(
          displayName: 'New Name',
          username: 'newuser',
          email: 'new@example.com',
          photoUrl: 'https://img.example.com/2.png',
        ),
      ),
      expect: () => [
        const AuthState(
          status: AuthAppStatus.profileUpdating,
          uid: 'uid-that-should-be-ignored',
          user: UserEntity(uid: 'uid-from-user', displayName: 'Old Name'),
        ),
        const AuthState(
          status: AuthAppStatus.profileUpdateSuccess,
          uid: 'uid-that-should-be-ignored',
          user: UserEntity(uid: 'uid-from-user', displayName: 'New Name'),
        ),
      ],
      verify: (_) {
        verify(
          () => updateProfileUsecase(
            const UpdateProfileParams(
              uid: 'uid-from-user',
              displayName: 'New Name',
              username: 'newuser',
              email: 'new@example.com',
              photoUrl: 'https://img.example.com/2.png',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'failure emits [profileUpdating, profileUpdateFailure]',
      build: () {
        when(
          () => updateProfileUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('update failed')));
        return buildBloc();
      },
      seed: () => const AuthState(
        user: UserEntity(uid: 'uid-from-user', displayName: 'Old Name'),
      ),
      act: (bloc) => bloc.add(
        const UpdateProfileDetailsEvent(
          displayName: 'New Name',
          username: 'newuser',
          email: 'new@example.com',
        ),
      ),
      expect: () => [
        const AuthState(
          status: AuthAppStatus.profileUpdating,
          user: UserEntity(uid: 'uid-from-user', displayName: 'Old Name'),
        ),
        const AuthState(
          status: AuthAppStatus.profileUpdateFailure,
          errorMessage: 'update failed',
          user: UserEntity(uid: 'uid-from-user', displayName: 'Old Name'),
        ),
      ],
    );
  });

  group('SignOutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'success resets to a BRAND-NEW default AuthState (not a copyWith of '
      'the previous one) — resendSeconds/errorMessage/etc. all reset',
      build: () {
        when(
          () => signOutUsecase(any()),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      seed: () => const AuthState(
        status: AuthAppStatus.authenticated,
        resendSeconds: 3,
        canResend: true,
        errorMessage: 'stale error',
        phoneNumber: '+19999999999',
        uid: 'stale-uid',
        isNewUser: true,
        imageUrl: 'stale-image',
        user: UserEntity(uid: 'stale-uid'),
      ),
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthState(
          status: AuthAppStatus.loading,
          resendSeconds: 3,
          canResend: true,
          errorMessage: 'stale error',
          phoneNumber: '+19999999999',
          uid: 'stale-uid',
          isNewUser: true,
          imageUrl: 'stale-image',
          user: UserEntity(uid: 'stale-uid'),
        ),
        const AuthState(status: AuthAppStatus.unAuthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'failure keeps prior fields (via copyWith) and sets failure status',
      build: () {
        when(
          () => signOutUsecase(any()),
        ).thenAnswer((_) async => Left(Failure('sign out failed')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthState(status: AuthAppStatus.loading),
        const AuthState(
          status: AuthAppStatus.failure,
          errorMessage: 'sign out failed',
        ),
      ],
    );
  });

  group('remote device deactivation + subscription/timer lifecycle', () {
    test(
      'when the watched stream emits false, the bloc signs out locally and '
      'transitions to unAuthenticated',
      () async {
        final controller = StreamController<bool>();
        const existingUser = UserEntity(uid: 'uid-deactivated');
        const authResult = AuthResult(
          uid: 'uid-deactivated',
          phoneNumber: '+10000000004',
          isNewUser: false,
          existingUser: existingUser,
        );
        when(
          () => verifyOtpUsecase(any()),
        ).thenAnswer((_) async => const Right(authResult));
        when(
          () => watchCurrentDeviceActiveStatusUsecase(any()),
        ).thenAnswer((_) => controller.stream);

        final bloc = buildBloc();
        bloc.add(const OtpVerifyEvent(otp: '123456'));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.status, AuthAppStatus.authenticated);
        verify(
          () => watchCurrentDeviceActiveStatusUsecase(
            const WatchCurrentDeviceActiveStatusParams(
              uid: 'uid-deactivated',
              deviceId: 'device-1',
            ),
          ),
        ).called(1);

        controller.add(false);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, AuthAppStatus.unAuthenticated);
        verify(() => signOutLocalOnlyUsecase(const NoParams())).called(1);

        await bloc.close();
        await controller.close();
      },
    );

    test(
      'SignOutEvent cancels the device-watch subscription so a later '
      'deactivation on the old stream is ignored',
      () async {
        final controller = StreamController<bool>();
        const existingUser = UserEntity(uid: 'uid-signout-cancel');
        const authResult = AuthResult(
          uid: 'uid-signout-cancel',
          phoneNumber: '+10000000005',
          isNewUser: false,
          existingUser: existingUser,
        );
        when(
          () => verifyOtpUsecase(any()),
        ).thenAnswer((_) async => const Right(authResult));
        when(
          () => watchCurrentDeviceActiveStatusUsecase(any()),
        ).thenAnswer((_) => controller.stream);
        when(
          () => signOutUsecase(any()),
        ).thenAnswer((_) async => const Right(null));

        final bloc = buildBloc();
        bloc.add(const OtpVerifyEvent(otp: '123456'));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.status, AuthAppStatus.authenticated);

        bloc.add(const SignOutEvent());
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.status, AuthAppStatus.unAuthenticated);

        controller.add(false);
        await Future.delayed(const Duration(milliseconds: 50));

        // The subscription was cancelled by SignOutEvent, so pushing another
        // value must NOT trigger a second, redundant local sign-out.
        verifyNever(() => signOutLocalOnlyUsecase(any()));
        expect(bloc.state.status, AuthAppStatus.unAuthenticated);

        await bloc.close();
        await controller.close();
      },
    );

    test(
      'close() cancels the timer and stream subscription: no further '
      'usecase calls happen after close, and close() completes without '
      'throwing',
      () async {
        final controller = StreamController<bool>();
        const existingUser = UserEntity(uid: 'uid-close');
        const authResult = AuthResult(
          uid: 'uid-close',
          phoneNumber: '+10000000006',
          isNewUser: false,
          existingUser: existingUser,
        );
        when(
          () => verifyOtpUsecase(any()),
        ).thenAnswer((_) async => const Right(authResult));
        when(
          () => watchCurrentDeviceActiveStatusUsecase(any()),
        ).thenAnswer((_) => controller.stream);

        final bloc = buildBloc();
        bloc.add(const OtpVerifyEvent(otp: '123456'));
        await Future.delayed(const Duration(milliseconds: 50));

        await bloc.close();

        // Pushing more data after close must not crash, and must not reach
        // the (now-cancelled) subscription's callback.
        expect(() => controller.add(false), returnsNormally);
        await Future.delayed(const Duration(milliseconds: 50));

        verifyNever(() => signOutLocalOnlyUsecase(any()));

        await controller.close();
      },
    );
  });
}

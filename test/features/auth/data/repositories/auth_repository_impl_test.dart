import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:fileflow/features/auth/data/models/user_model.dart';
import 'package:fileflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRemoteDatasource mockDatasource;
  late MockDeviceInfoService mockDeviceInfoService;
  late AuthRepositoryImpl repository;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(const DeviceModel());
    registerFallbackValue(const UserModel());
  });

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    mockDeviceInfoService = MockDeviceInfoService();
    repository = AuthRepositoryImpl(mockDatasource, mockDeviceInfoService);
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
  });

  group('sendOtp', () {
    test('returns Right(verificationId) on success', () async {
      when(() => mockDatasource.sendOtp(any(), any())).thenAnswer((_) async => 'vid-1');

      final result = await repository.sendOtp('+10000000000');

      result.fold((_) => fail('expected a Right'), (id) => expect(id, 'vid-1'));
      verify(() => mockDatasource.sendOtp('+10000000000', any())).called(1);
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(() => mockDatasource.sendOtp(any(), any())).thenThrow(Exception('network down'));

      final result = await repository.sendOtp('+10000000000');

      result.fold(
        (failure) => expect(failure.message, contains('network down')),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('resendOtp', () {
    test('returns Right(verificationId) on success', () async {
      when(() => mockDatasource.resendOtp(any(), any())).thenAnswer((_) async => 'vid-2');

      final result = await repository.resendOtp('+10000000000');

      result.fold((_) => fail('expected a Right'), (id) => expect(id, 'vid-2'));
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(() => mockDatasource.resendOtp(any(), any())).thenThrow(Exception('boom'));

      final result = await repository.resendOtp('+10000000000');

      result.fold(
        (failure) => expect(failure.message, contains('boom')),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('createAccount', () {
    test('attaches current device info and returns Right(entity) on success', () async {
      const deviceInfo = DeviceEntity(deviceId: 'dev-1', deviceName: 'Pixel');
      when(() => mockDeviceInfoService.getDeviceInfo()).thenAnswer((_) async => deviceInfo);
      const createdModel = UserModel(uid: 'uid-1', email: 'a@example.com', username: 'alice');
      when(() => mockDatasource.createUserInFirestore(any())).thenAnswer((_) async => createdModel);

      const inputEntity = UserEntity(uid: 'uid-1', email: 'a@example.com', username: 'alice');
      final result = await repository.createAccount(inputEntity);

      result.fold((_) => fail('expected a Right'), (entity) {
        expect(entity.uid, 'uid-1');
        expect(entity.email, 'a@example.com');
      });

      final captured = verify(() => mockDatasource.createUserInFirestore(captureAny())).captured;
      final passedModel = captured.single as UserModel;
      expect(passedModel.devices?.keys, contains('dev-1'));
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(() => mockDeviceInfoService.getDeviceInfo()).thenAnswer(
        (_) async => const DeviceEntity(deviceId: 'dev-1'),
      );
      when(() => mockDatasource.createUserInFirestore(any())).thenThrow(Failure('Username already taken.'));

      final result = await repository.createAccount(const UserEntity(uid: 'uid-1'));

      result.fold(
        (failure) => expect(failure.message, 'Username already taken.'),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('updateProfile', () {
    test('returns Right(entity) on success', () async {
      const updatedModel = UserModel(uid: 'uid-1', username: 'newname');
      when(
        () => mockDatasource.updateUserProfile(
          uid: any(named: 'uid'),
          displayName: any(named: 'displayName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          photoUrl: any(named: 'photoUrl'),
        ),
      ).thenAnswer((_) async => updatedModel);

      final result = await repository.updateProfile(uid: 'uid-1', username: 'newname');

      result.fold((_) => fail('expected a Right'), (entity) => expect(entity.username, 'newname'));
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(
        () => mockDatasource.updateUserProfile(
          uid: any(named: 'uid'),
          displayName: any(named: 'displayName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          photoUrl: any(named: 'photoUrl'),
        ),
      ).thenThrow(Failure('Email already taken.'));

      final result = await repository.updateProfile(uid: 'uid-1', email: 'taken@example.com');

      result.fold(
        (failure) => expect(failure.message, 'Email already taken.'),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('getCurrentDeviceId', () {
    test('returns Right(deviceId) when present', () async {
      when(() => mockDeviceInfoService.getDeviceInfo()).thenAnswer(
        (_) async => const DeviceEntity(deviceId: 'dev-9'),
      );

      final result = await repository.getCurrentDeviceId();

      result.fold((_) => fail('expected a Right'), (id) => expect(id, 'dev-9'));
    });

    test('returns Right("unknown") when deviceId is null', () async {
      when(() => mockDeviceInfoService.getDeviceInfo()).thenAnswer((_) async => const DeviceEntity());

      final result = await repository.getCurrentDeviceId();

      result.fold((_) => fail('expected a Right'), (id) => expect(id, 'unknown'));
    });

    test('returns Left(Failure) when the service throws', () async {
      when(() => mockDeviceInfoService.getDeviceInfo()).thenThrow(Exception('no plugin'));

      final result = await repository.getCurrentDeviceId();

      result.fold(
        (failure) => expect(failure.message, contains('no plugin')),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('logoutDevice', () {
    test('returns Right(null) on success', () async {
      when(
        () => mockDatasource.setDeviceActive(any(), any(), isActive: any(named: 'isActive')),
      ).thenAnswer((_) async {});

      final result = await repository.logoutDevice(uid: 'uid-1', deviceId: 'dev-1');

      expect(result, const Right<Failure, void>(null));
      verify(() => mockDatasource.setDeviceActive('uid-1', 'dev-1', isActive: false)).called(1);
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(
        () => mockDatasource.setDeviceActive(any(), any(), isActive: any(named: 'isActive')),
      ).thenThrow(Exception('fail'));

      final result = await repository.logoutDevice(uid: 'uid-1', deviceId: 'dev-1');

      result.fold(
        (failure) => expect(failure.message, contains('fail')),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('logoutAllOtherDevices', () {
    test('returns Right(null) on success', () async {
      when(() => mockDatasource.deactivateOtherDevices(any(), any())).thenAnswer((_) async {});

      final result = await repository.logoutAllOtherDevices(uid: 'uid-1', currentDeviceId: 'dev-1');

      expect(result, const Right<Failure, void>(null));
      verify(() => mockDatasource.deactivateOtherDevices('uid-1', 'dev-1')).called(1);
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(() => mockDatasource.deactivateOtherDevices(any(), any())).thenThrow(Exception('fail'));

      final result = await repository.logoutAllOtherDevices(uid: 'uid-1', currentDeviceId: 'dev-1');

      result.fold(
        (failure) => expect(failure.message, contains('fail')),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('signOutLocalOnly', () {
    test('returns Right(null) on success', () async {
      when(() => mockDatasource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOutLocalOnly();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockDatasource.signOut()).called(1);
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(() => mockDatasource.signOut()).thenThrow(Exception('fail'));

      final result = await repository.signOutLocalOnly();

      result.fold(
        (failure) => expect(failure.message, contains('fail')),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('signOut', () {
    test('happy path: deactivates the current device THEN signs out, in order', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid-1');
      when(() => mockDeviceInfoService.getDeviceInfo()).thenAnswer(
        (_) async => const DeviceEntity(deviceId: 'dev-1'),
      );
      when(
        () => mockDatasource.setDeviceActive(any(), any(), isActive: any(named: 'isActive')),
      ).thenAnswer((_) async {});
      when(() => mockDatasource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right<Failure, void>(null));
      verifyInOrder([
        () => mockDatasource.getCurrentFirebaseUser(),
        () => mockDeviceInfoService.getDeviceInfo(),
        () => mockDatasource.setDeviceActive('uid-1', 'dev-1', isActive: false),
        () => mockDatasource.signOut(),
      ]);
    });

    test('swallows a device-deactivation failure and still signs out', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid-1');
      when(() => mockDeviceInfoService.getDeviceInfo()).thenThrow(Exception('device info unavailable'));
      when(() => mockDatasource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockDatasource.signOut()).called(1);
      verifyNever(() => mockDatasource.setDeviceActive(any(), any(), isActive: any(named: 'isActive')));
    });

    test('skips the deactivation branch entirely when there is no current user', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(null);
      when(() => mockDatasource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right<Failure, void>(null));
      verifyNever(() => mockDeviceInfoService.getDeviceInfo());
      verifyNever(() => mockDatasource.setDeviceActive(any(), any(), isActive: any(named: 'isActive')));
      verify(() => mockDatasource.signOut()).called(1);
    });

    test('returns Left(Failure) when signOut() itself throws', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(null);
      when(() => mockDatasource.signOut()).thenThrow(Exception('signOut failed'));

      final result = await repository.signOut();

      result.fold(
        (failure) => expect(failure.message, contains('signOut failed')),
        (_) => fail('expected a Left'),
      );
    });
  });

  // ---------------------------------------------------------------------
  // Shared credential-processing helper (`_processUserCredential`), exercised
  // through both public entry points that use it: verifyOtp and
  // signInWithAutoVerifiedCredential.
  // ---------------------------------------------------------------------

  void runProcessUserCredentialTests({
    required String description,
    required Future<Either<Failure, AuthResult>> Function() invoke,
    required void Function() stubEntryPointReturnsCredential,
  }) {
    group(description, () {
      test('user == null returns Left(Failure("Verification Failed"))', () async {
        when(() => mockUserCredential.user).thenReturn(null);
        stubEntryPointReturnsCredential();

        final result = await invoke();

        result.fold(
          (failure) => expect(failure.message, 'Verification Failed'),
          (_) => fail('expected a Left'),
        );
      });

      test('existing user: updates device info and returns Right(isNewUser: false)', () async {
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-1');
        when(() => mockUser.phoneNumber).thenReturn('+10000000000');
        stubEntryPointReturnsCredential();

        const existingModel = UserModel(uid: 'uid-1', email: 'existing@example.com');
        when(() => mockDatasource.getUserFromFirestore('uid-1')).thenAnswer((_) async => existingModel);
        const deviceInfo = DeviceEntity(deviceId: 'dev-1');
        when(() => mockDeviceInfoService.getDeviceInfo()).thenAnswer((_) async => deviceInfo);
        when(() => mockDatasource.updateDeviceInfo(any(), any())).thenAnswer((_) async {});

        final result = await invoke();

        result.fold((_) => fail('expected a Right'), (authResult) {
          expect(authResult.uid, 'uid-1');
          expect(authResult.phoneNumber, '+10000000000');
          expect(authResult.isNewUser, isFalse);
          expect(authResult.existingUser, existingModel.toEntity());
        });
        verify(() => mockDatasource.updateDeviceInfo('uid-1', deviceInfo.toModel())).called(1);
      });

      test('no existing user: returns Right(isNewUser: true) without updating device info', () async {
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('uid-2');
        when(() => mockUser.phoneNumber).thenReturn('+19999999999');
        stubEntryPointReturnsCredential();

        when(() => mockDatasource.getUserFromFirestore('uid-2')).thenAnswer((_) async => null);

        final result = await invoke();

        result.fold((_) => fail('expected a Right'), (authResult) {
          expect(authResult.uid, 'uid-2');
          expect(authResult.phoneNumber, '+19999999999');
          expect(authResult.isNewUser, isTrue);
          expect(authResult.existingUser, isNull);
        });
        verifyNever(() => mockDatasource.updateDeviceInfo(any(), any()));
      });
    });
  }

  runProcessUserCredentialTests(
    description: 'verifyOtp (via shared _processUserCredential helper)',
    invoke: () => repository.verifyOtp('123456'),
    stubEntryPointReturnsCredential: () {
      when(() => mockDatasource.verifyOtp(any())).thenAnswer((_) async => mockUserCredential);
    },
  );

  final autoVerifiedCredential = PhoneAuthProvider.credential(verificationId: 'vid', smsCode: '000000');
  runProcessUserCredentialTests(
    description: 'signInWithAutoVerifiedCredential (via shared _processUserCredential helper)',
    invoke: () => repository.signInWithAutoVerifiedCredential(autoVerifiedCredential),
    stubEntryPointReturnsCredential: () {
      when(() => mockDatasource.signInWithCredential(autoVerifiedCredential)).thenAnswer(
        (_) async => mockUserCredential,
      );
    },
  );

  group('signInWithAutoVerifiedCredential type-check', () {
    test('a non-PhoneAuthCredential returns Left without touching the datasource', () async {
      const dynamic notACredential = 'not-a-credential';

      final result = await repository.signInWithAutoVerifiedCredential(notACredential);

      result.fold(
        (failure) => expect(failure.message, 'Invalid credential'),
        (_) => fail('expected a Left'),
      );
      verifyZeroInteractions(mockDatasource);
    });
  });

  group('watchDevices', () {
    test('filters to active devices and sorts by lastLoginAt descending', () async {
      final devices = {
        'd1': DeviceModel(deviceId: 'd1', isActive: true, lastLoginAt: DateTime.utc(2024, 1, 1)),
        'd2': DeviceModel(deviceId: 'd2', isActive: false, lastLoginAt: DateTime.utc(2024, 1, 3)),
        'd3': DeviceModel(deviceId: 'd3', isActive: true, lastLoginAt: DateTime.utc(2024, 1, 2)),
      };
      final userModel = UserModel(uid: 'uid-1', devices: devices);
      when(() => mockDatasource.watchUser('uid-1')).thenAnswer((_) => Stream.value(userModel));

      final stream = repository.watchDevices('uid-1');

      // NOTE: watchDevices does NOT convert DeviceModel -> DeviceEntity via
      // toEntity() (unlike _processUserCredential, which does). The emitted
      // list is typed List<DeviceEntity> but actually contains the original
      // DeviceModel instances. Since Equatable's == also compares
      // runtimeType, a DeviceModel is NOT equal to an otherwise-identical
      // DeviceEntity — so we compare against the raw models here, not
      // `.toEntity()`.
      await expectLater(
        stream,
        emits([devices['d3'], devices['d1']]),
      );
    });

    test('emits an empty list when the user (or their devices) is absent', () async {
      when(() => mockDatasource.watchUser('uid-1')).thenAnswer((_) => Stream.value(null));

      await expectLater(repository.watchDevices('uid-1'), emits(<DeviceEntity>[]));
    });
  });

  group('watchCurrentDeviceActiveStatus', () {
    test('emits true when the device is active', () async {
      const userModel = UserModel(
        uid: 'uid-1',
        devices: {'dev-1': DeviceModel(deviceId: 'dev-1', isActive: true)},
      );
      when(() => mockDatasource.watchUser('uid-1')).thenAnswer((_) => Stream.value(userModel));

      await expectLater(repository.watchCurrentDeviceActiveStatus('uid-1', 'dev-1'), emits(true));
    });

    test('emits false when the device is inactive', () async {
      const userModel = UserModel(
        uid: 'uid-1',
        devices: {'dev-1': DeviceModel(deviceId: 'dev-1', isActive: false)},
      );
      when(() => mockDatasource.watchUser('uid-1')).thenAnswer((_) => Stream.value(userModel));

      await expectLater(repository.watchCurrentDeviceActiveStatus('uid-1', 'dev-1'), emits(false));
    });

    test('emits false when the device is not present at all', () async {
      const userModel = UserModel(uid: 'uid-1', devices: {});
      when(() => mockDatasource.watchUser('uid-1')).thenAnswer((_) => Stream.value(userModel));

      await expectLater(repository.watchCurrentDeviceActiveStatus('uid-1', 'missing'), emits(false));
    });
  });

  group('checkAuthState', () {
    test('not logged in when there is no current Firebase user', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(null);

      final result = await repository.checkAuthState();

      result.fold((_) => fail('expected a Right'), (status) {
        expect(status.isLoggedIn, isFalse);
        expect(status.isNewUser, isFalse);
        expect(status.user, isNull);
      });
    });

    test('logged in, existing user found in Firestore', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid-1');
      when(() => mockUser.phoneNumber).thenReturn('+10000000000');
      const existingModel = UserModel(uid: 'uid-1', email: 'a@example.com');
      when(() => mockDatasource.getUserFromFirestore('uid-1')).thenAnswer((_) async => existingModel);

      final result = await repository.checkAuthState();

      result.fold((_) => fail('expected a Right'), (status) {
        expect(status.isLoggedIn, isTrue);
        expect(status.isNewUser, isFalse);
        expect(status.uid, 'uid-1');
        expect(status.phoneNumber, '+10000000000');
        expect(status.user, existingModel.toEntity());
      });
    });

    test('logged in, no Firestore doc yet -> isNewUser: true', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid-2');
      when(() => mockUser.phoneNumber).thenReturn('+19999999999');
      when(() => mockDatasource.getUserFromFirestore('uid-2')).thenAnswer((_) async => null);

      final result = await repository.checkAuthState();

      result.fold((_) => fail('expected a Right'), (status) {
        expect(status.isLoggedIn, isTrue);
        expect(status.isNewUser, isTrue);
        expect(status.uid, 'uid-2');
        expect(status.phoneNumber, '+19999999999');
        expect(status.user, isNull);
      });
    });

    test('returns Left(Failure) when the datasource throws', () async {
      when(() => mockDatasource.getCurrentFirebaseUser()).thenThrow(Exception('boom'));

      final result = await repository.checkAuthState();

      result.fold(
        (failure) => expect(failure.message, contains('boom')),
        (_) => fail('expected a Left'),
      );
    });
  });
}

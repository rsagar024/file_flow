import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:fileflow/features/auth/data/models/device_model.dart';
import 'package:fileflow/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/firestore_seed.dart';
import '../../../../helpers/mocks.dart';

// Dummy fallback callbacks — mocktail needs a concrete value of each
// (non-nullable) function-typedef type whenever any()/captureAny() is used
// for the corresponding named parameter of `verifyPhoneNumber`.
void _fallbackVerificationCompleted(PhoneAuthCredential credential) {}
void _fallbackVerificationFailed(FirebaseAuthException error) {}
void _fallbackCodeSent(String verificationId, int? forceResendingToken) {}
void _fallbackCodeAutoRetrievalTimeout(String verificationId) {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late AuthRemoteDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(_fallbackVerificationCompleted);
    registerFallbackValue(_fallbackVerificationFailed);
    registerFallbackValue(_fallbackCodeSent);
    registerFallbackValue(_fallbackCodeAutoRetrievalTimeout);
    registerFallbackValue(const Duration());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    datasource = AuthRemoteDatasourceImpl(mockFirebaseAuth, fakeFirestore);
  });

  // Stubs `verifyPhoneNumber` so the call succeeds regardless of arguments.
  void stubVerifyPhoneNumber({bool withForceResendingToken = false}) {
    if (withForceResendingToken) {
      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((_) async {});
    } else {
      when(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          timeout: any(named: 'timeout'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((_) async {});
    }
  }

  // Retrieves the 4 callbacks passed to the most recent `verifyPhoneNumber`
  // call, in [verificationCompleted, verificationFailed, codeSent,
  // codeAutoRetrievalTimeout] order.
  List<dynamic> captureCallbacks({bool withForceResendingToken = false}) {
    if (withForceResendingToken) {
      return verify(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
          verificationCompleted: captureAny(named: 'verificationCompleted'),
          verificationFailed: captureAny(named: 'verificationFailed'),
          codeSent: captureAny(named: 'codeSent'),
          codeAutoRetrievalTimeout: captureAny(named: 'codeAutoRetrievalTimeout'),
        ),
      ).captured;
    }
    return verify(
      () => mockFirebaseAuth.verifyPhoneNumber(
        phoneNumber: any(named: 'phoneNumber'),
        timeout: any(named: 'timeout'),
        verificationCompleted: captureAny(named: 'verificationCompleted'),
        verificationFailed: captureAny(named: 'verificationFailed'),
        codeSent: captureAny(named: 'codeSent'),
        codeAutoRetrievalTimeout: captureAny(named: 'codeAutoRetrievalTimeout'),
      ),
    ).captured;
  }

  group('sendOtp', () {
    test('codeSent resolves the returned future with the verification id', () async {
      stubVerifyPhoneNumber();

      final future = datasource.sendOtp('+10000000000', (_) {});
      final captured = captureCallbacks();
      final codeSent = captured[2] as PhoneCodeSent;

      codeSent('vid-1', 99);

      expect(await future, 'vid-1');
    });

    test('verificationFailed completes the future with e.message ?? e.code (raw String)', () async {
      stubVerifyPhoneNumber();

      final future = datasource.sendOtp('+10000000000', (_) {});
      final captured = captureCallbacks();
      final verificationFailed = captured[1] as PhoneVerificationFailed;

      verificationFailed(
        FirebaseAuthException(code: 'invalid-phone-number', message: 'The phone number is invalid.'),
      );

      await expectLater(future, throwsA('The phone number is invalid.'));
    });

    test('verificationFailed falls back to e.code when message is null', () async {
      stubVerifyPhoneNumber();

      final future = datasource.sendOtp('+10000000000', (_) {});
      final captured = captureCallbacks();
      final verificationFailed = captured[1] as PhoneVerificationFailed;

      verificationFailed(FirebaseAuthException(code: 'invalid-phone-number'));

      await expectLater(future, throwsA('invalid-phone-number'));
    });

    test('verificationCompleted invokes onAutoVerified with the credential, not the future', () async {
      stubVerifyPhoneNumber();
      PhoneAuthCredential? received;

      final future = datasource.sendOtp('+10000000000', (credential) {
        received = credential;
      });
      final captured = captureCallbacks();
      final verificationCompleted = captured[0] as PhoneVerificationCompleted;
      final credential = PhoneAuthProvider.credential(verificationId: 'vid-auto', smsCode: '111111');

      verificationCompleted(credential);

      expect(received, credential);
      // The completer is never completed by verificationCompleted, so the
      // future stays pending — avoid hanging the test by not awaiting it.
      unawaited(future);
    });
  });

  group('resendOtp', () {
    test('codeSent resolves the returned future with the verification id', () async {
      stubVerifyPhoneNumber(withForceResendingToken: true);

      final future = datasource.resendOtp('+10000000000', (_) {});
      final captured = captureCallbacks(withForceResendingToken: true);
      final codeSent = captured[2] as PhoneCodeSent;

      codeSent('vid-2', 5);

      expect(await future, 'vid-2');
    });

    test(
      'verificationFailed completes the future with a Failure(e.code) — '
      'KNOWN INCONSISTENCY: sendOtp completes with a raw String (e.message ?? e.code) '
      'while resendOtp completes with a Failure(e.code) object. Testing both as-is, not fixing.',
      () async {
        stubVerifyPhoneNumber(withForceResendingToken: true);

        final future = datasource.resendOtp('+10000000000', (_) {});
        final captured = captureCallbacks(withForceResendingToken: true);
        final verificationFailed = captured[1] as PhoneVerificationFailed;

        verificationFailed(
          FirebaseAuthException(code: 'invalid-phone-number', message: 'The phone number is invalid.'),
        );

        try {
          await future;
          fail('expected future to complete with an error');
        } catch (e) {
          expect(e, isA<Failure>());
          expect((e as Failure).message, 'invalid-phone-number');
        }
      },
    );

    test('verificationCompleted invokes onAutoVerified with the credential, not the future', () async {
      stubVerifyPhoneNumber(withForceResendingToken: true);
      PhoneAuthCredential? received;

      final future = datasource.resendOtp('+10000000000', (credential) {
        received = credential;
      });
      final captured = captureCallbacks(withForceResendingToken: true);
      final verificationCompleted = captured[0] as PhoneVerificationCompleted;
      final credential = PhoneAuthProvider.credential(verificationId: 'vid-auto-2', smsCode: '222222');

      verificationCompleted(credential);

      expect(received, credential);
      unawaited(future);
    });

    test('forceResendingToken is passed through from the token captured by a prior sendOtp', () async {
      stubVerifyPhoneNumber();

      final sendFuture = datasource.sendOtp('+10000000000', (_) {});
      final sendCaptured = captureCallbacks();
      (sendCaptured[2] as PhoneCodeSent)('vid-1', 42);
      await sendFuture;

      stubVerifyPhoneNumber(withForceResendingToken: true);

      final resendFuture = datasource.resendOtp('+10000000000', (_) {});
      // Capture forceResendingToken in the SAME verify() call as the
      // callbacks: mocktail marks matched invocations as "verified" once a
      // verify() call matches them, excluding them from matching in any
      // later verify() call — so the token must be captured here, not via a
      // separate verify() afterwards.
      final resendCaptured = verify(
        () => mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          timeout: any(named: 'timeout'),
          forceResendingToken: captureAny(named: 'forceResendingToken'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: captureAny(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).captured;
      // NOTE: mocktail's `captured` list order follows the real method's
      // parameter declaration order, not the order matchers are written in
      // the when()/verify() call — codeSent is declared before
      // forceResendingToken in FirebaseAuth.verifyPhoneNumber.
      final codeSent = resendCaptured[0] as PhoneCodeSent;
      final forceResendingToken = resendCaptured[1] as int?;
      codeSent('vid-3', 7);
      await resendFuture;

      expect(forceResendingToken, 42);
    });
  });

  group('verifyOtp', () {
    test('throws a Failure when no verification id has been captured yet', () async {
      await expectLater(datasource.verifyOtp('123456'), throwsA(isA<Failure>()));
    });

    test('signs in with the credential built from the captured verification id', () async {
      stubVerifyPhoneNumber();
      final sendFuture = datasource.sendOtp('+10000000000', (_) {});
      final captured = captureCallbacks();
      (captured[2] as PhoneCodeSent)('vid-happy', null);
      await sendFuture;

      final mockUserCredential = MockUserCredential();
      when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((_) async => mockUserCredential);

      final result = await datasource.verifyOtp('654321');

      expect(result, mockUserCredential);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });
  });

  group('getCurrentFirebaseUser', () {
    test('passes through FirebaseAuth.currentUser', () {
      final mockUser = MockUser();
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      expect(datasource.getCurrentFirebaseUser(), mockUser);
    });

    test('returns null when there is no current user', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      expect(datasource.getCurrentFirebaseUser(), isNull);
    });
  });

  group('getUserFromFirestore', () {
    test('returns a parsed UserModel when the doc exists', () async {
      await seedUserDoc(
        fakeFirestore,
        'uid-1',
        email: 'a@example.com',
        username: 'alice',
        displayName: 'Alice',
      );

      final result = await datasource.getUserFromFirestore('uid-1');

      expect(result, isNotNull);
      expect(result!.uid, 'uid-1');
      expect(result.email, 'a@example.com');
      expect(result.username, 'alice');
      expect(result.displayName, 'Alice');
    });

    test('returns null when the doc does not exist', () async {
      final result = await datasource.getUserFromFirestore('missing-uid');
      expect(result, isNull);
    });
  });

  group('createUserInFirestore', () {
    UserModel buildUserModel({
      String uid = 'uid-1',
      String? email = 'new@example.com',
      String? username = 'newuser',
    }) {
      return UserModel(
        uid: uid,
        email: email,
        username: username,
        displayName: 'New User',
        phoneNumber: '+10000000000',
      );
    }

    test('writes the doc with default storage quota fields', () async {
      final result = await datasource.createUserInFirestore(buildUserModel());

      expect(result.storageUsedBytes, 0);
      expect(result.storageLimitBytes, 5368709120);
      expect(result.totalFilesCount, 0);
      expect(result.createdAt, isNotNull);
      expect(result.updatedAt, isNotNull);

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final data = doc.data()!;
      expect(data['storageUsedBytes'], 0);
      expect(data['storageLimitBytes'], 5368709120);
      expect(data['totalFilesCount'], 0);
      expect(data['email'], 'new@example.com');
      expect(data['username'], 'newuser');
    });

    test('throws kEmailAlreadyTaken when the email is already used', () async {
      await seedUserDoc(fakeFirestore, 'existing-uid', email: 'new@example.com');

      await expectLater(
        datasource.createUserInFirestore(buildUserModel()),
        throwsA(
          isA<Failure>().having((f) => f.message, 'message', StringConstants.kEmailAlreadyTaken),
        ),
      );
    });

    test('throws kUsernameAlreadyTaken when the username is already used', () async {
      await seedUserDoc(fakeFirestore, 'existing-uid', email: 'someone-else@example.com', username: 'newuser');

      await expectLater(
        datasource.createUserInFirestore(buildUserModel(email: 'unique@example.com')),
        throwsA(
          isA<Failure>().having((f) => f.message, 'message', StringConstants.kUsernameAlreadyTaken),
        ),
      );
    });
  });

  group('updateDeviceInfo', () {
    test('adds the new device alongside an existing map-shaped device', () async {
      await seedUserDoc(
        fakeFirestore,
        'uid-1',
        devices: {'existing-device': deviceJson(deviceId: 'existing-device', deviceName: 'Existing')},
      );

      await datasource.updateDeviceInfo(
        'uid-1',
        const DeviceModel(deviceId: 'new-device', deviceName: 'New'),
      );

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final devices = doc.data()!['devices'] as Map<String, dynamic>;
      expect(devices.keys, containsAll(['existing-device', 'new-device']));
      expect((devices['existing-device'] as Map)['deviceName'], 'Existing');
      expect((devices['new-device'] as Map)['deviceName'], 'New');
    });

    test('self-heals a legacy List-shaped devices field into a fresh map with just the new device', () async {
      await seedUserDoc(fakeFirestore, 'uid-1');
      await fakeFirestore.collection('users').doc('uid-1').update({'devices': <dynamic>[]});

      await datasource.updateDeviceInfo(
        'uid-1',
        const DeviceModel(deviceId: 'new-device', deviceName: 'New'),
      );

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final devices = doc.data()!['devices'];
      expect(devices, isA<Map>());
      expect((devices as Map).keys, ['new-device']);
      expect((devices['new-device'] as Map)['deviceName'], 'New');
    });
  });

  group('deactivateOtherDevices', () {
    test('deactivates every device except the excluded one', () async {
      await seedUserDoc(
        fakeFirestore,
        'uid-1',
        devices: {
          'device-1': deviceJson(deviceId: 'device-1'),
          'device-2': deviceJson(deviceId: 'device-2'),
        },
      );

      await datasource.deactivateOtherDevices('uid-1', 'device-1');

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final devices = doc.data()!['devices'] as Map<String, dynamic>;
      expect((devices['device-1'] as Map)['isActive'], true);
      expect((devices['device-2'] as Map)['isActive'], false);
    });

    test('is a no-op when devices is legacy List-shaped', () async {
      await seedUserDoc(fakeFirestore, 'uid-1');
      await fakeFirestore.collection('users').doc('uid-1').update({
        'devices': [
          {'deviceId': 'device-1'},
        ],
      });

      await datasource.deactivateOtherDevices('uid-1', 'device-1');

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      expect(doc.data()!['devices'], [
        {'deviceId': 'device-1'},
      ]);
    });
  });

  group('setDeviceActive', () {
    test('flips the isActive flag for the given device, leaving others untouched', () async {
      await seedUserDoc(
        fakeFirestore,
        'uid-1',
        email: 'a@example.com',
        devices: {'device-1': deviceJson(deviceId: 'device-1', deviceName: 'Phone', isActive: true)},
      );

      await datasource.setDeviceActive('uid-1', 'device-1', isActive: false);

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final data = doc.data()!;
      final devices = data['devices'] as Map<String, dynamic>;
      expect((devices['device-1'] as Map)['isActive'], false);
      expect((devices['device-1'] as Map)['deviceName'], 'Phone');
      expect(data['email'], 'a@example.com');
    });
  });

  group('updateUserProfile', () {
    test('updates all fields and refreshes updatedAt', () async {
      await seedUserDoc(
        fakeFirestore,
        'uid-1',
        email: 'old@example.com',
        username: 'olduser',
        displayName: 'Old Name',
        photoUrl: 'old-photo',
      );

      final result = await datasource.updateUserProfile(
        uid: 'uid-1',
        displayName: 'New Name',
        username: 'newuser',
        email: 'new@example.com',
        photoUrl: 'new-photo',
      );

      expect(result.displayName, 'New Name');
      expect(result.username, 'newuser');
      expect(result.email, 'new@example.com');
      expect(result.photoUrl, 'new-photo');

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final data = doc.data()!;
      expect(data['updatedAt'], isNot(DateTime.utc(2024, 1, 1).toIso8601String()));
    });

    test('a partial update leaves the other previously-seeded fields unchanged', () async {
      await seedUserDoc(
        fakeFirestore,
        'uid-1',
        email: 'keep@example.com',
        username: 'olduser',
        displayName: 'Keep Name',
        photoUrl: 'keep-photo',
      );

      await datasource.updateUserProfile(uid: 'uid-1', username: 'newuser');

      final doc = await readUserDoc(fakeFirestore, 'uid-1');
      final data = doc.data()!;
      expect(data['username'], 'newuser');
      expect(data['email'], 'keep@example.com');
      expect(data['displayName'], 'Keep Name');
      expect(data['photoUrl'], 'keep-photo');
    });

    test('throws kUsernameAlreadyTaken when another user already has that username', () async {
      await seedUserDoc(fakeFirestore, 'uid-a', username: 'taken');
      await seedUserDoc(fakeFirestore, 'uid-b', username: 'free');

      await expectLater(
        datasource.updateUserProfile(uid: 'uid-b', username: 'taken'),
        throwsA(
          isA<Failure>().having((f) => f.message, 'message', StringConstants.kUsernameAlreadyTaken),
        ),
      );
    });

    test('throws kEmailAlreadyTaken when another user already has that email', () async {
      await seedUserDoc(fakeFirestore, 'uid-a', email: 'taken@example.com');
      await seedUserDoc(fakeFirestore, 'uid-b', email: 'free@example.com');

      await expectLater(
        datasource.updateUserProfile(uid: 'uid-b', email: 'taken@example.com'),
        throwsA(
          isA<Failure>().having((f) => f.message, 'message', StringConstants.kEmailAlreadyTaken),
        ),
      );
    });

    test('succeeds when a user "reclaims" their own current username', () async {
      await seedUserDoc(fakeFirestore, 'uid-a', username: 'mine');

      final result = await datasource.updateUserProfile(uid: 'uid-a', username: 'mine');

      expect(result.username, 'mine');
    });
  });

  group('signInWithCredential / signOut', () {
    test('signInWithCredential passes through to FirebaseAuth', () async {
      final credential = PhoneAuthProvider.credential(verificationId: 'vid', smsCode: '000000');
      final mockUserCredential = MockUserCredential();
      when(() => mockFirebaseAuth.signInWithCredential(credential)).thenAnswer((_) async => mockUserCredential);

      final result = await datasource.signInWithCredential(credential);

      expect(result, mockUserCredential);
      verify(() => mockFirebaseAuth.signInWithCredential(credential)).called(1);
    });

    test('signOut passes through to FirebaseAuth', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await datasource.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });
}

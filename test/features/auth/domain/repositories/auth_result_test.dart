import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthResult', () {
    const existingUser = UserEntity(uid: 'uid-1', email: 'user@example.com');

    AuthResult buildResult({
      String uid = 'uid-1',
      String phoneNumber = '+10000000000',
      bool isNewUser = false,
      UserEntity? existingUserValue = existingUser,
    }) {
      return AuthResult(
        uid: uid,
        phoneNumber: phoneNumber,
        isNewUser: isNewUser,
        existingUser: existingUserValue,
      );
    }

    test('two instances with identical fields are equal', () {
      expect(buildResult(), buildResult());
    });

    test('a differing field breaks equality', () {
      expect(buildResult(), isNot(equals(buildResult(uid: 'uid-2'))));
      expect(buildResult(), isNot(equals(buildResult(phoneNumber: '+19999999999'))));
      expect(buildResult(), isNot(equals(buildResult(isNewUser: true))));
      expect(buildResult(), isNot(equals(buildResult(existingUserValue: null))));
    });
  });

  group('AuthStatusResult', () {
    // TODO(fileflow): AuthStatusResult.props (lib/features/auth/domain/repositories/auth_repository.dart)
    // currently does `throw UnimplementedError()` instead of returning
    // `[isLoggedIn, isNewUser, user, uid, phoneNumber]`. This means Equatable's
    // `==`/`hashCode` — and therefore `expect(x, someAuthStatusResult)` — throw
    // at runtime for ANY AuthStatusResult instance. Until this is fixed in
    // production code, no test (or app code) should construct-and-compare
    // AuthStatusResult instances via `==`; always assert its fields
    // individually instead. This test documents the current (buggy) behavior
    // so a fix is a deliberate, visible change rather than a silent one.
    test('AuthStatusResult.props throws UnimplementedError (KNOWN BUG — see auth_repository.dart)', () {
      const result = AuthStatusResult(
        isLoggedIn: true,
        isNewUser: false,
        uid: 'uid-1',
        phoneNumber: '+10000000000',
      );

      expect(() => result.props, throwsUnimplementedError);
    });

    test('fields are still readable individually despite the props bug', () {
      const user = UserEntity(uid: 'uid-1');
      const result = AuthStatusResult(
        isLoggedIn: true,
        isNewUser: true,
        user: user,
        uid: 'uid-1',
        phoneNumber: '+10000000000',
      );

      expect(result.isLoggedIn, isTrue);
      expect(result.isNewUser, isTrue);
      expect(result.user, user);
      expect(result.uid, 'uid-1');
      expect(result.phoneNumber, '+10000000000');
    });
  });
}

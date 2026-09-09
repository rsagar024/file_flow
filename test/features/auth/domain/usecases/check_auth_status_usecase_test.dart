import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late CheckAuthStatusUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = CheckAuthStatusUsecase(mockAuthRepository);
  });

  const params = NoParams();

  test('returns AuthStatusResult from the repository on success', () async {
    // NOTE: AuthStatusResult.props throws UnimplementedError (see
    // auth_result_test.dart), so we must only ever construct ONE instance
    // here and never compare two separately-constructed instances via `==`.
    const authStatusResult = AuthStatusResult(
      isLoggedIn: true,
      isNewUser: false,
      uid: 'uid-1',
      phoneNumber: '+10000000000',
    );
    when(() => mockAuthRepository.checkAuthState()).thenAnswer((_) async => const Right(authStatusResult));

    final result = await usecase(params);

    verify(() => mockAuthRepository.checkAuthState()).called(1);
    result.fold((_) => fail('expected a Right'), (r) {
      expect(r.isLoggedIn, authStatusResult.isLoggedIn);
      expect(r.isNewUser, authStatusResult.isNewUser);
      expect(r.uid, authStatusResult.uid);
      expect(r.phoneNumber, authStatusResult.phoneNumber);
      expect(r.user, authStatusResult.user);
    });
  });

  test('returns a Failure from the repository on failure', () async {
    when(() => mockAuthRepository.checkAuthState()).thenAnswer((_) async => Left(Failure('check failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.checkAuthState()).called(1);
    result.fold((failure) => expect(failure.message, 'check failed'), (_) => fail('expected a Left'));
  });
}

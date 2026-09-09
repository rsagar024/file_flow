import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late VerifyOtpUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = VerifyOtpUsecase(mockAuthRepository);
  });

  const params = VerifyOtpParams('123456');

  test('calls repository.verifyOtp with the exact otp and returns its result', () async {
    const authResult = AuthResult(uid: 'uid-1', phoneNumber: '+10000000000', isNewUser: true);
    when(() => mockAuthRepository.verifyOtp('123456')).thenAnswer((_) async => const Right(authResult));

    final result = await usecase(params);

    verify(() => mockAuthRepository.verifyOtp('123456')).called(1);
    expect(result, const Right<Failure, AuthResult>(authResult));
  });

  test('returns a Failure from the repository on failure', () async {
    when(() => mockAuthRepository.verifyOtp('123456')).thenAnswer((_) async => Left(Failure('verify otp failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.verifyOtp('123456')).called(1);
    result.fold((failure) => expect(failure.message, 'verify otp failed'), (_) => fail('expected a Left'));
  });
}

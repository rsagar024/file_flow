import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ResendOtpUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = ResendOtpUsecase(mockAuthRepository);
  });

  const params = ResendOtpParams('+10000000000');

  test('calls repository.resendOtp with the exact phone number and returns its result', () async {
    when(() => mockAuthRepository.resendOtp('+10000000000')).thenAnswer((_) async => const Right('verification-id'));

    final result = await usecase(params);

    verify(() => mockAuthRepository.resendOtp('+10000000000')).called(1);
    expect(result, const Right<Failure, String>('verification-id'));
  });

  test('returns a Failure from the repository on failure', () async {
    when(
      () => mockAuthRepository.resendOtp('+10000000000'),
    ).thenAnswer((_) async => Left(Failure('resend otp failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.resendOtp('+10000000000')).called(1);
    result.fold((failure) => expect(failure.message, 'resend otp failed'), (_) => fail('expected a Left'));
  });
}

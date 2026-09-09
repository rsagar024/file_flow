import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignOutUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOutUsecase(mockAuthRepository);
  });

  const params = NoParams();

  test('returns Right(null) from the repository on success', () async {
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async => const Right(null));

    final result = await usecase(params);

    verify(() => mockAuthRepository.signOut()).called(1);
    expect(result, const Right<Failure, void>(null));
  });

  test('returns a Failure from the repository on failure', () async {
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async => Left(Failure('sign out failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.signOut()).called(1);
    result.fold((failure) => expect(failure.message, 'sign out failed'), (_) => fail('expected a Left'));
  });
}

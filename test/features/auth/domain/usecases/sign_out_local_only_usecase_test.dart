import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_local_only_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignOutLocalOnlyUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOutLocalOnlyUsecase(mockAuthRepository);
  });

  const params = NoParams();

  test('returns Right(null) from the repository on success', () async {
    when(() => mockAuthRepository.signOutLocalOnly()).thenAnswer((_) async => const Right(null));

    final result = await usecase(params);

    verify(() => mockAuthRepository.signOutLocalOnly()).called(1);
    expect(result, const Right<Failure, void>(null));
  });

  test('returns a Failure from the repository on failure', () async {
    when(() => mockAuthRepository.signOutLocalOnly()).thenAnswer((_) async => Left(Failure('local sign out failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.signOutLocalOnly()).called(1);
    result.fold((failure) => expect(failure.message, 'local sign out failed'), (_) => fail('expected a Left'));
  });
}

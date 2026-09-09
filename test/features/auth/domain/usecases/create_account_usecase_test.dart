import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late CreateAccountUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = CreateAccountUsecase(mockAuthRepository);
  });

  const params = CreateAccountParams(
    uid: 'uid-1',
    phoneNumber: '+10000000000',
    displayName: 'Display Name',
    username: 'username',
    email: 'user@example.com',
    photoUrl: 'https://example.com/photo.png',
  );

  const expectedEntity = UserEntity(
    uid: 'uid-1',
    phoneNumber: '+10000000000',
    displayName: 'Display Name',
    username: 'username',
    email: 'user@example.com',
    photoUrl: 'https://example.com/photo.png',
  );

  test('builds a UserEntity from params and calls repository.createAccount with it', () async {
    when(() => mockAuthRepository.createAccount(any())).thenAnswer((_) async => const Right(expectedEntity));

    final result = await usecase(params);

    final captured = verify(() => mockAuthRepository.createAccount(captureAny())).captured;
    expect(captured, hasLength(1));
    final passedEntity = captured.single as UserEntity;
    expect(passedEntity.uid, params.uid);
    expect(passedEntity.phoneNumber, params.phoneNumber);
    expect(passedEntity.displayName, params.displayName);
    expect(passedEntity.username, params.username);
    expect(passedEntity.email, params.email);
    expect(passedEntity.photoUrl, params.photoUrl);

    expect(result, const Right<Failure, UserEntity>(expectedEntity));
  });

  test('returns a Failure from the repository on failure', () async {
    when(() => mockAuthRepository.createAccount(any())).thenAnswer((_) async => Left(Failure('create failed')));

    final result = await usecase(params);

    result.fold((failure) => expect(failure.message, 'create failed'), (_) => fail('expected a Left'));
  });
}

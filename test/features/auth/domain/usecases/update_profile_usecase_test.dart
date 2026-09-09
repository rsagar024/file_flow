import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late UpdateProfileUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UpdateProfileUsecase(mockAuthRepository);
  });

  const params = UpdateProfileParams(
    uid: 'uid-1',
    displayName: 'New Name',
    username: 'new-username',
    email: 'new@example.com',
    photoUrl: 'https://example.com/new.png',
  );

  const expectedEntity = UserEntity(uid: 'uid-1', displayName: 'New Name');

  test('calls repository.updateProfile with the exact fields and returns its result', () async {
    when(
      () => mockAuthRepository.updateProfile(
        uid: 'uid-1',
        displayName: 'New Name',
        username: 'new-username',
        email: 'new@example.com',
        photoUrl: 'https://example.com/new.png',
      ),
    ).thenAnswer((_) async => const Right(expectedEntity));

    final result = await usecase(params);

    verify(
      () => mockAuthRepository.updateProfile(
        uid: 'uid-1',
        displayName: 'New Name',
        username: 'new-username',
        email: 'new@example.com',
        photoUrl: 'https://example.com/new.png',
      ),
    ).called(1);
    expect(result, const Right<Failure, UserEntity>(expectedEntity));
  });

  test('returns a Failure from the repository on failure', () async {
    when(
      () => mockAuthRepository.updateProfile(
        uid: 'uid-1',
        displayName: 'New Name',
        username: 'new-username',
        email: 'new@example.com',
        photoUrl: 'https://example.com/new.png',
      ),
    ).thenAnswer((_) async => Left(Failure('update failed')));

    final result = await usecase(params);

    result.fold((failure) => expect(failure.message, 'update failed'), (_) => fail('expected a Left'));
  });
}

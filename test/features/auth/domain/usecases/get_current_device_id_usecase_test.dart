import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/get_current_device_id_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late GetCurrentDeviceIdUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentDeviceIdUsecase(mockAuthRepository);
  });

  const params = NoParams();

  test('returns the device id from the repository on success', () async {
    when(() => mockAuthRepository.getCurrentDeviceId()).thenAnswer((_) async => const Right('device-1'));

    final result = await usecase(params);

    verify(() => mockAuthRepository.getCurrentDeviceId()).called(1);
    expect(result, const Right<Failure, String>('device-1'));
  });

  test('returns a Failure from the repository on failure', () async {
    when(() => mockAuthRepository.getCurrentDeviceId()).thenAnswer((_) async => Left(Failure('no device id')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.getCurrentDeviceId()).called(1);
    result.fold((failure) => expect(failure.message, 'no device id'), (_) => fail('expected a Left'));
  });
}

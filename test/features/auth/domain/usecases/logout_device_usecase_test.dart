import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_device_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late LogoutDeviceUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutDeviceUsecase(mockAuthRepository);
  });

  const params = LogoutDeviceParams(uid: 'uid-1', deviceId: 'device-1');

  test('calls repository.logoutDevice with the exact uid and deviceId and returns its result', () async {
    when(
      () => mockAuthRepository.logoutDevice(uid: 'uid-1', deviceId: 'device-1'),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase(params);

    verify(() => mockAuthRepository.logoutDevice(uid: 'uid-1', deviceId: 'device-1')).called(1);
    expect(result, const Right<Failure, void>(null));
  });

  test('returns a Failure from the repository on failure', () async {
    when(
      () => mockAuthRepository.logoutDevice(uid: 'uid-1', deviceId: 'device-1'),
    ).thenAnswer((_) async => Left(Failure('logout device failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.logoutDevice(uid: 'uid-1', deviceId: 'device-1')).called(1);
    result.fold((failure) => expect(failure.message, 'logout device failed'), (_) => fail('expected a Left'));
  });
}

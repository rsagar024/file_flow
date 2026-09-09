import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_all_other_devices_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late LogoutAllOtherDevicesUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutAllOtherDevicesUsecase(mockAuthRepository);
  });

  const params = LogoutAllOtherDevicesParams(uid: 'uid-1', currentDeviceId: 'device-1');

  test('calls repository.logoutAllOtherDevices with the exact uid and currentDeviceId and returns its result', () async {
    when(
      () => mockAuthRepository.logoutAllOtherDevices(uid: 'uid-1', currentDeviceId: 'device-1'),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase(params);

    verify(() => mockAuthRepository.logoutAllOtherDevices(uid: 'uid-1', currentDeviceId: 'device-1')).called(1);
    expect(result, const Right<Failure, void>(null));
  });

  test('returns a Failure from the repository on failure', () async {
    when(
      () => mockAuthRepository.logoutAllOtherDevices(uid: 'uid-1', currentDeviceId: 'device-1'),
    ).thenAnswer((_) async => Left(Failure('logout all failed')));

    final result = await usecase(params);

    verify(() => mockAuthRepository.logoutAllOtherDevices(uid: 'uid-1', currentDeviceId: 'device-1')).called(1);
    result.fold((failure) => expect(failure.message, 'logout all failed'), (_) => fail('expected a Left'));
  });
}

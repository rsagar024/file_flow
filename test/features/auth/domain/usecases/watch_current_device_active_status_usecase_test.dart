import 'package:fileflow/features/auth/domain/usecases/watch_current_device_active_status_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late WatchCurrentDeviceActiveStatusUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = WatchCurrentDeviceActiveStatusUsecase(mockAuthRepository);
  });

  const params = WatchCurrentDeviceActiveStatusParams(uid: 'uid-1', deviceId: 'device-1');

  test('re-emits the same values the repository stream produces', () async {
    when(
      () => mockAuthRepository.watchCurrentDeviceActiveStatus('uid-1', 'device-1'),
    ).thenAnswer((_) => Stream.fromIterable([true, false, true]));

    await expectLater(usecase(params), emitsInOrder([true, false, true, emitsDone]));

    verify(() => mockAuthRepository.watchCurrentDeviceActiveStatus('uid-1', 'device-1')).called(1);
  });
}

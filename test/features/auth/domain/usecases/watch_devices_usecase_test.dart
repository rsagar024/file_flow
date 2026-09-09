import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_devices_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late WatchDevicesUsecase usecase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = WatchDevicesUsecase(mockAuthRepository);
  });

  const uid = 'uid-1';

  test('re-emits the same values the repository stream produces', () async {
    const devicesA = <DeviceEntity>[DeviceEntity(deviceId: 'device-1')];
    const devicesB = <DeviceEntity>[
      DeviceEntity(deviceId: 'device-1'),
      DeviceEntity(deviceId: 'device-2'),
    ];
    when(() => mockAuthRepository.watchDevices(uid)).thenAnswer((_) => Stream.fromIterable([devicesA, devicesB]));

    await expectLater(usecase(uid), emitsInOrder([devicesA, devicesB, emitsDone]));

    verify(() => mockAuthRepository.watchDevices(uid)).called(1);
  });
}

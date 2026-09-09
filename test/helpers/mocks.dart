import 'package:fileflow/core/error/failure.dart';
import 'package:fileflow/core/services/device_info_service.dart';
import 'package:fileflow/core/services/image_picker_service.dart';
import 'package:fileflow/core/services/theme_preferences_service.dart';
import 'package:fileflow/core/usecase/usecase.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fileflow/features/auth/domain/entities/device_entity.dart';
import 'package:fileflow/features/auth/domain/entities/user_entity.dart';
import 'package:fileflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:fileflow/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/create_account_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/get_current_device_id_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_all_other_devices_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/logout_device_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_local_only_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_current_device_active_status_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_devices_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Repository / datasource / service mocks
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class MockDeviceInfoService extends Mock implements DeviceInfoService {}

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockThemePreferencesService extends Mock implements ThemePreferencesService {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockConfirmationResult extends Mock implements ConfirmationResult {}

// ---------------------------------------------------------------------------
// Usecase mocks (one per auth usecase — used by AuthBloc/DevicesBloc tests)
// ---------------------------------------------------------------------------

class MockSendOtpUsecase extends Mock implements SendOtpUsecase {}

class MockVerifyOtpUsecase extends Mock implements VerifyOtpUsecase {}

class MockResendOtpUsecase extends Mock implements ResendOtpUsecase {}

class MockCheckAuthStatusUsecase extends Mock implements CheckAuthStatusUsecase {}

class MockCreateAccountUsecase extends Mock implements CreateAccountUsecase {}

class MockSignOutUsecase extends Mock implements SignOutUsecase {}

class MockGetCurrentDeviceIdUsecase extends Mock implements GetCurrentDeviceIdUsecase {}

class MockWatchCurrentDeviceActiveStatusUsecase extends Mock implements WatchCurrentDeviceActiveStatusUsecase {}

class MockSignOutLocalOnlyUsecase extends Mock implements SignOutLocalOnlyUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockLogoutDeviceUsecase extends Mock implements LogoutDeviceUsecase {}

class MockLogoutAllOtherDevicesUsecase extends Mock implements LogoutAllOtherDevicesUsecase {}

class MockWatchDevicesUsecase extends Mock implements WatchDevicesUsecase {}

/// Registers dummy fallback values for every non-primitive type mocktail's
/// `any()`/`captureAny()` matchers are used with anywhere in the suite.
/// Call this once, e.g. from a shared `setUpAll` in each test file (calling
/// it multiple times across files is harmless — mocktail lets you
/// re-register the same fallback value).
void registerFallbackValues() {
  registerFallbackValue(const NoParams());
  registerFallbackValue(const UserEntity());
  registerFallbackValue(const DeviceEntity());
  registerFallbackValue(
    const CreateAccountParams(
      uid: 'fallback-uid',
      phoneNumber: '+10000000000',
      displayName: 'fallback',
      username: 'fallback',
      email: 'fallback@example.com',
      photoUrl: '',
    ),
  );
  registerFallbackValue(const UpdateProfileParams(uid: 'fallback-uid'));
  registerFallbackValue(const SendOtpParams('+10000000000'));
  registerFallbackValue(const ResendOtpParams('+10000000000'));
  registerFallbackValue(const VerifyOtpParams('000000'));
  registerFallbackValue(const LogoutDeviceParams(uid: 'fallback-uid', deviceId: 'fallback-device'));
  registerFallbackValue(
    const LogoutAllOtherDevicesParams(uid: 'fallback-uid', currentDeviceId: 'fallback-device'),
  );
  registerFallbackValue(
    const WatchCurrentDeviceActiveStatusParams(uid: 'fallback-uid', deviceId: 'fallback-device'),
  );
  registerFallbackValue(Failure('fallback failure'));
  registerFallbackValue(
    PhoneAuthProvider.credential(verificationId: 'fallback-verification-id', smsCode: '000000'),
  );
  registerFallbackValue(ImageSource.gallery);
}

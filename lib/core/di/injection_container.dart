import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fileflow/core/services/device_info_service.dart';
import 'package:fileflow/core/services/image_picker_service.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fileflow/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:fileflow/features/auth/data/repositories/auth_repository_impl.dart';
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
import 'package:fileflow/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_current_device_active_status_usecase.dart';
import 'package:fileflow/features/auth/domain/usecases/watch_devices_usecase.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/profile/presentation/bloc/devices/devices_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  _registerFirebase();
  _registerCoreService();
  _registerDataSources();
  _registerRepositories();
  _registerUseCase();
  _registerBlocs();
}

void _registerFirebase() {
  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
}

void _registerCoreService() {
  getIt
    ..registerLazySingleton<DeviceInfoService>(() => DeviceInfoService())
    ..registerLazySingleton<ImagePickerService>(() => ImagePickerService());
}

void _registerDataSources() {
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(getIt(), getIt()),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
}

void _registerUseCase() {
  getIt
    ..registerLazySingleton(() => SendOtpUsecase(getIt()))
    ..registerLazySingleton(() => VerifyOtpUsecase(getIt()))
    ..registerLazySingleton(() => ResendOtpUsecase(getIt()))
    ..registerLazySingleton(() => CheckAuthStatusUsecase(getIt()))
    ..registerLazySingleton(() => CreateAccountUsecase(getIt()))
    ..registerLazySingleton(() => SignOutUsecase(getIt()))
    ..registerLazySingleton(() => GetCurrentDeviceIdUsecase(getIt()))
    ..registerLazySingleton(
      () => WatchCurrentDeviceActiveStatusUsecase(getIt()),
    )
    ..registerLazySingleton(() => SignOutLocalOnlyUsecase(getIt()))
    ..registerLazySingleton(() => WatchDevicesUsecase(getIt()))
    ..registerLazySingleton(() => LogoutDeviceUsecase(getIt()))
    ..registerLazySingleton(() => LogoutAllOtherDevicesUsecase(getIt()));
}

void _registerBlocs() {
  getIt
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    )
    ..registerFactory<DevicesBloc>(
      () => DevicesBloc(getIt(), getIt(), getIt(), getIt()),
    );
}

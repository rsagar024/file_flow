import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/routes/app_route.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(const FileFlowApp());
}

class FileFlowApp extends StatelessWidget {
  const FileFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>())],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: StringConstants.kAppName,
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: AppRoute.routes,
      ),
    );
  }
}

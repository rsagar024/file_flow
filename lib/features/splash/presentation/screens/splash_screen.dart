import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/enums/app_state/app_state.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends FileFlowBackgroundState<SplashScreen> {
  @override
  void onInit() {
    super.onInit();
    getIt<AuthBloc>().add(AuthCheckStatusEvent());
  }

  @override
  Widget buildContent(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.state != curr.state,
      listener: (context, state) {
        if (state.state == AuthAppState.newUserDetected) {
          context.go(CreateAccountScreen.routeName);
        } else if (state.state == AuthAppState.authenticated) {
          context.go(DashboardScreen.routeName);
        } else if (state.state == AuthAppState.unAuthenticated || state.state == AuthAppState.initial) {
          context.go(LoginScreen.routeName);
        }
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(child: SvgPicture.asset('assets/images/app_logo.svg')),
      ),
    );
  }
}

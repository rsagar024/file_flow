import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/common/widgets/pin_text_field_widget.dart';
import 'package:fileflow/core/enums/app_state/app_state.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/utilities/debug_logger.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/create_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/otp-verification';

  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends FileFlowBackgroundState<OtpVerificationScreen> {
  final pinTextField = PinTextFieldWidget(length: 6, obscure: false);

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        animateColor: false,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.state != curr.state,
        listener: (context, state) {
          if (state.state == AuthAppState.newUserDetected) {
            context.go(CreateAccountScreen.routeName);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                SvgPicture.asset('assets/icons/ic_logo.svg', height: 80),
                const SizedBox(height: 10),
                const Text(
                  StringConstants.kOtpVerification,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    StringConstants.kEnterThe6DigitCode,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.neutral300),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: pinTextField),
                const Text(
                  StringConstants.kDidNtReceiveTheCode,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.neutral400),
                ),
                BlocSelector<AuthBloc, AuthState, ({int seconds, bool canResend})>(
                  selector: (state) => (seconds: state.resendSeconds, canResend: state.canResend),
                  builder: (context, data) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 40),
                      child: GestureDetector(
                        onTap: data.canResend
                            ? () {
                                context.read<AuthBloc>().add(
                                  OtpResendEvent(phoneNumber: context.read<AuthBloc>().state.phoneNumber ?? ''),
                                );
                              }
                            : null,
                        child: Text(
                          data.canResend
                              ? StringConstants.kResendCode
                              : '${StringConstants.kResendIn} 00:${data.seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: data.canResend ? AppColors.primary : AppColors.neutral400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) => state.state == AuthAppState.loading,
                  builder: (context, isLoading) {
                    return FileFlowButton(
                      text: StringConstants.kVerify,
                      textColor: AppColors.white,
                      icon: const Icon(Icons.security, color: AppColors.white),
                      iconAlignment: IconAlignment.end,
                      isLoading: isLoading,
                      onPressed: () {
                        if (pinTextField.controller.text.trim().length == 6) {
                          context.read<AuthBloc>().add(OtpVerifyEvent(otp: pinTextField.controller.text.trim()));
                        } else {
                          printError('Invalid Otp');
                        }
                      },
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

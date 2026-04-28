import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/pin_text_field_widget.dart';
import 'package:fileflow/core/enums/app_state/app_state.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        animateColor: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
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
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9)),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    StringConstants.kEnterThe6DigitCode,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: pinTextField),
                const Text(
                  StringConstants.kDidNtReceiveTheCode,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF64748B)),
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
                            color: data.canResend ? const Color(0xFF0062FF) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (pinTextField.controller.text.trim().length == 6) {
                      context.read<AuthBloc>().add(OtpVerifyEvent(otp: pinTextField.controller.text.trim()));
                    } else {
                      printError('Invalid Otp');
                    }
                  },
                  label: const Text(
                    StringConstants.kVerify,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  icon: const Icon(Icons.security, color: Colors.white),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF0062FF),
                  ),
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

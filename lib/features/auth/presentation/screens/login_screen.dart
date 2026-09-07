import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/common/widgets/phone_field/countries.dart';
import 'package:fileflow/core/common/widgets/phone_field/phone_field.dart';
import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/utilities/custom_snackbar.dart';
import 'package:fileflow/core/utilities/debug_logger.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends FileFlowBackgroundState<LoginScreen> {
  final actions = [StringConstants.kHelpCenter, StringConstants.kTerms, StringConstants.kPrivacy];
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Country? country;
  String? phone;

  @override
  void onDispose() {
    super.onDispose();
    _phoneController.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthAppStatus.otpSent) {
            context.push(OtpVerificationScreen.routeName);
          } else if (state.status == AuthAppStatus.failure) {
            printError(state.errorMessage ?? 'Unknown error');
            CustomSnackbar.show(
              context: context,
              message: state.errorMessage ?? 'Unknown error',
              type: SnackbarType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/icons/ic_logo.svg', height: 80),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                          children: const [
                            TextSpan(text: StringConstants.kFile),
                            TextSpan(
                              text: StringConstants.kFlow,
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 48),
                        child: Text(
                          StringConstants.kSecureSyncYourWorkflowAnywhere,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: context.colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  StringConstants.kWelcomeBack,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  child: Text(
                    StringConstants.kEnterYourMobileNumberToSignIn,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: context.colors.textSecondary),
                  ),
                ),
                Text(
                  StringConstants.kMobileNumber.toUpperCase(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: context.colors.textSecondary),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: PhoneField(
                      labelText: StringConstants.kPhone,
                      controller: _phoneController,
                      selectedDialCode: StringConstants.kIndianDialCode,
                      isRequired: true,
                      onValidationChanged: (isValid, country, phoneNumber) {
                        setState(() {
                          if (isValid && phoneNumber.isNotNullOrEmpty) {
                            this.country = country;
                            phone = phoneNumber;
                          } else {
                            phone = null;
                          }
                        });
                      },
                    ),
                  ),
                ),
                BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) => state.status == AuthAppStatus.loading,
                  builder: (context, isLoading) {
                    return FileFlowButton(
                      text: StringConstants.kSendOtp,
                      textColor: AppColors.white,
                      icon: const Icon(CupertinoIcons.arrow_right, color: AppColors.white),
                      iconAlignment: IconAlignment.end,
                      isLoading: isLoading,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (country?.dialCode != null && phone != null) {
                            context.read<AuthBloc>().add(OtpSendEvent(phoneNumber: '+${country!.dialCode}$phone'));
                          }
                        }
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: context.colors.surface),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    actions.length,
                    (index) => Text(
                      actions[index],
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: context.colors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

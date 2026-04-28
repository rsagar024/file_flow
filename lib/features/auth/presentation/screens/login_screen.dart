import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/common/widgets/phone_field/countries.dart';
import 'package:fileflow/core/common/widgets/phone_field/phone_field.dart';
import 'package:fileflow/core/enums/app_state/app_state.dart';
import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
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
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.state == AuthAppState.otpSent) {
            context.push(OtpVerificationScreen.routeName);
          }
        },
        child: SafeArea(
          child: Padding(
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
                        text: const TextSpan(
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9)),
                          children: [
                            TextSpan(text: StringConstants.kFile),
                            TextSpan(
                              text: StringConstants.kFlow,
                              style: TextStyle(color: Color(0xFF0062FF)),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 48),
                        child: Text(
                          StringConstants.kSecureSyncYourWorkflowAnywhere,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  StringConstants.kWelcomeBack,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9)),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 32),
                  child: Text(
                    StringConstants.kEnterYourMobileNumberToSignIn,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
                  ),
                ),
                Text(
                  StringConstants.kMobileNumber.toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
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
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (country?.dialCode != null && phone != null) {
                        context.read<AuthBloc>().add(OtpSendEvent(phoneNumber: '+${country!.dialCode}$phone'));
                      }
                    }
                  },
                  label: const Text(
                    StringConstants.kSendOtp,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  icon: const Icon(CupertinoIcons.arrow_right, color: Colors.white),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF0062FF),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFF1E293B)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    actions.length,
                    (index) => Text(
                      actions[index],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
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

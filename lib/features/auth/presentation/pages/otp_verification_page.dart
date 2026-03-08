import 'package:fileflow/core/common/widgets/custom_button.dart';
import 'package:fileflow/core/common/widgets/pin_text_field_widget.dart';
import 'package:fileflow/core/extensions/media_query_extension.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/core/utilities/debug_logger.dart';
import 'package:flutter/material.dart';

class OtpVerificationPage extends StatefulWidget {
  static const routeName = 'otp_verification_page';

  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final pinTextField = PinTextFieldWidget(length: 6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [const Spacer(), pinTextField, const Spacer()],
        ),
      ),
      bottomNavigationBar: CustomButton(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(bottom: context.bottomPadding + (context.bottomPaddingZero ? 30 : 10)),
        onPressed: () {
          printInfo('Pin Code : ${pinTextField.controller.text}');
        },
        text: 'Get Otp',
        textStyle: CustomTextStyles.custom12Regular.copyWith(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        borderRadius: BorderRadius.circular(30),
        backgroundColor: Colors.white,
      ),
    );
  }
}

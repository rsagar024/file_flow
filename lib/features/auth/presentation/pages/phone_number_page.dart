import 'package:fileflow/core/common/widgets/custom_button.dart';
import 'package:fileflow/core/common/widgets/phone_field/countries.dart';
import 'package:fileflow/core/common/widgets/phone_field/phone_field.dart';
import 'package:fileflow/core/extensions/media_query_extension.dart';
import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/core/utilities/debug_logger.dart';
import 'package:fileflow/core/validator/validator.dart';
import 'package:flutter/material.dart';

class PhoneNumberPage extends StatefulWidget {
  static const routeName = 'phone_number_page';

  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  Country? country;
  String? phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const Spacer(),
            Image.asset('assets/images/logo.png'),
            PhoneField(
              labelText: 'phone',
              controller: _phoneController,
              selectedDialCode: '91',
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
            CustomButton(
              margin: const EdgeInsets.symmetric(vertical: 30),
              onPressed: () {
                if (phone == null) {
                  printInfo('Phone Number is required');
                } else {
                  final result = Validator.validatePhoneNumber(number: phone ?? '', country: country);
                  if (result.$1) {
                    printDebug('Country code : ${country?.dialCode} -- Phone Number : $phone');
                  } else {
                    printWarning(result.$2);
                  }
                }
              },
              text: 'Get Otp',
              textStyle: CustomTextStyles.custom12Regular.copyWith(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              borderRadius: BorderRadius.circular(30),
              backgroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

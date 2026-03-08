import 'package:fileflow/core/common/widgets/phone_field/countries.dart';

class Validator {
  static bool hasMinimumLength(Country? country, String number) {
    return country?.minLength == number.length;
  }

  static (bool, String) validatePhoneNumber({required String number, Country? country}) {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanNumber.length != country?.minLength) {
      return (false, 'Number must be exactly ${country?.minLength} digits');
    }

    if (country?.startingDigits.isEmpty ?? true) {
      return (true, '');
    }

    final isValidStart = country?.startingDigits.any((digit) => cleanNumber.startsWith(digit)) ?? false;

    if (!isValidStart) {
      return (false, 'Number must start with ${country?.startingDigits.join(', ')}');
    }

    return (true, '');
  }
}

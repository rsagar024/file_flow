import 'package:fileflow/core/resources/common/string_constants.dart';

class Validator {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return StringConstants.kFullNameIsRequired;
    }
    final name = value.trim();
    if (name.length < 3) {
      return StringConstants.kNameMustBeAtLeast3Character;
    }
    final regex = RegExp(r'^[a-zA-Z ]+$');
    if (!regex.hasMatch(name)) {
      return StringConstants.kOnlyLettersAndSpacesAllowed;
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return StringConstants.kUsernameIsRequired;
    }
    final username = value.trim();
    if (username.contains(' ')) {
      return StringConstants.kUsernameMustNotContainSpaces;
    }
    if (username.length < 3) {
      return StringConstants.kMinimum3CharactersRequired;
    }
    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(username)) {
      return StringConstants.kOnlyLowercaseLettersNumbers;
    }
    if (username.startsWith('_') || username.endsWith('_')) {
      return StringConstants.kCannotStartOrEndWithUnderscore;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return StringConstants.kEmailIsRequired;
    }
    final email = value.trim();
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(email)) {
      return StringConstants.kEnterAValidEmailAddress;
    }
    return null;
  }
}

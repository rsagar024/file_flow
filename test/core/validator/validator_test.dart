import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/validator/validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateFullName', () {
    test('returns kFullNameIsRequired for null', () {
      expect(Validator.validateFullName(null), StringConstants.kFullNameIsRequired);
    });

    test('returns kFullNameIsRequired for empty/whitespace-only input', () {
      expect(Validator.validateFullName(''), StringConstants.kFullNameIsRequired);
      expect(Validator.validateFullName('   '), StringConstants.kFullNameIsRequired);
    });

    test('returns kNameMustBeAtLeast3Character for a trimmed name shorter than 3 characters', () {
      expect(Validator.validateFullName('Al'), StringConstants.kNameMustBeAtLeast3Character);
      expect(Validator.validateFullName(' Al '), StringConstants.kNameMustBeAtLeast3Character);
    });

    test('returns kOnlyLettersAndSpacesAllowed for names containing digits/symbols', () {
      expect(Validator.validateFullName('Jane99'), StringConstants.kOnlyLettersAndSpacesAllowed);
      expect(Validator.validateFullName('Jane_Doe'), StringConstants.kOnlyLettersAndSpacesAllowed);
    });

    test('returns null for a valid name', () {
      expect(Validator.validateFullName('Jane Doe'), isNull);
      expect(Validator.validateFullName('  Jane Doe  '), isNull);
    });
  });

  group('validateUsername', () {
    test('returns kUsernameIsRequired for null/empty/whitespace-only input', () {
      expect(Validator.validateUsername(null), StringConstants.kUsernameIsRequired);
      expect(Validator.validateUsername(''), StringConstants.kUsernameIsRequired);
      expect(Validator.validateUsername('   '), StringConstants.kUsernameIsRequired);
    });

    test('returns kUsernameMustNotContainSpaces when the trimmed value still contains a space', () {
      expect(Validator.validateUsername('jane doe'), StringConstants.kUsernameMustNotContainSpaces);
    });

    test('returns kMinimum3CharactersRequired for a value shorter than 3 characters', () {
      expect(Validator.validateUsername('jd'), StringConstants.kMinimum3CharactersRequired);
    });

    test('returns kOnlyLowercaseLettersNumbers for uppercase letters or invalid symbols', () {
      expect(Validator.validateUsername('JaneDoe'), StringConstants.kOnlyLowercaseLettersNumbers);
      expect(Validator.validateUsername('jane-doe'), StringConstants.kOnlyLowercaseLettersNumbers);
    });

    test('returns kCannotStartOrEndWithUnderscore when the username starts or ends with "_"', () {
      expect(Validator.validateUsername('_janedoe'), StringConstants.kCannotStartOrEndWithUnderscore);
      expect(Validator.validateUsername('janedoe_'), StringConstants.kCannotStartOrEndWithUnderscore);
    });

    test('returns null for a valid username', () {
      expect(Validator.validateUsername('jane_doe123'), isNull);
    });
  });

  group('validateEmail', () {
    test('returns kEmailIsRequired for null/empty/whitespace-only input', () {
      expect(Validator.validateEmail(null), StringConstants.kEmailIsRequired);
      expect(Validator.validateEmail(''), StringConstants.kEmailIsRequired);
      expect(Validator.validateEmail('   '), StringConstants.kEmailIsRequired);
    });

    test('returns kEnterAValidEmailAddress for a malformed address', () {
      expect(Validator.validateEmail('not-an-email'), StringConstants.kEnterAValidEmailAddress);
      expect(Validator.validateEmail('jane@'), StringConstants.kEnterAValidEmailAddress);
      expect(Validator.validateEmail('jane@example'), StringConstants.kEnterAValidEmailAddress);
    });

    test('returns null for a valid email address', () {
      expect(Validator.validateEmail('jane@example.com'), isNull);
      expect(Validator.validateEmail('  jane@example.com  '), isNull);
    });
  });
}

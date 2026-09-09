import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isNullOrEmpty / isNotNullOrEmpty', () {
    test('null is null-or-empty', () {
      const String? value = null;
      expect(value.isNullOrEmpty, isTrue);
      expect(value.isNotNullOrEmpty, isFalse);
    });

    test('empty string is null-or-empty', () {
      expect(''.isNullOrEmpty, isTrue);
      expect(''.isNotNullOrEmpty, isFalse);
    });

    test('non-empty string is not null-or-empty', () {
      expect('hello'.isNullOrEmpty, isFalse);
      expect('hello'.isNotNullOrEmpty, isTrue);
    });
  });

  group('capitalize', () {
    test('uppercases the first letter and keeps the rest', () {
      expect('jane'.capitalize, 'Jane');
    });

    test('is a no-op when the first letter is already uppercase', () {
      expect('Jane'.capitalize, 'Jane');
    });
  });

  group('getTimeStamp', () {
    test('extracts hh:mm:ss when an hour prefix is present', () {
      expect('1:23:45.678'.getTimeStamp, '1:23:45');
    });

    test('extracts mm:ss when no hour prefix is present', () {
      expect('23:45.678'.getTimeStamp, '23:45');
    });

    test('returns null when the string has no trailing ".digits" timestamp', () {
      expect('not a timestamp'.getTimeStamp, isNull);
    });

    test('returns null for a null receiver', () {
      const String? value = null;
      expect(value.getTimeStamp, isNull);
    });
  });

  group('isNetworkUrl', () {
    test('returns true for an http URL', () {
      expect('http://example.com'.isNetworkUrl, isTrue);
    });

    test('returns true for an https URL', () {
      expect('https://example.com/path'.isNetworkUrl, isTrue);
    });

    test('returns false for a non-http(s) scheme', () {
      expect('ftp://example.com'.isNetworkUrl, isFalse);
    });

    test('returns false for a schemeless string', () {
      expect('not-a-url'.isNetworkUrl, isFalse);
    });

    test('returns false for a null receiver', () {
      const String? value = null;
      expect(value.isNetworkUrl, isFalse);
    });
  });

  group('maskEmail', () {
    test('leaves the username unmasked when its length is 4 or fewer characters', () {
      expect('jane@example.com'.maskEmail, 'jane@example.com');
    });

    test('masks the middle of a longer username, keeping the first/last 2 characters', () {
      expect('johndoe@example.com'.maskEmail, 'jo***oe@example.com');
    });

    test('masks a 5-character username with a single asterisk in the middle', () {
      expect('abcde@example.com'.maskEmail, 'ab*de@example.com');
    });

    test('returns the original string when it does not split into exactly 2 "@" parts', () {
      expect('no-at-sign'.maskEmail, 'no-at-sign');
      expect('a@b@c'.maskEmail, 'a@b@c');
    });

    test('returns an empty string for a null receiver with no "@"', () {
      const String? value = null;
      expect(value.maskEmail, '');
    });
  });
}

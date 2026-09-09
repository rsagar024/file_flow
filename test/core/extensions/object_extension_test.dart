import 'package:fileflow/core/extensions/object_extension.dart';
import 'package:flutter_test/flutter_test.dart';

// `logException`/`printInConsole` are side-effecting `print()` wrappers
// gated on `kDebugMode` — these tests only assert they don't throw for the
// input types the codebase actually calls them with; asserting captured
// stdout content isn't worth the added complexity for two print() calls.
void main() {
  group('logException', () {
    test('does not throw for a String receiver', () {
      expect(() => 'some error'.logException(), returnsNormally);
    });

    test('does not throw for an Exception receiver', () {
      expect(() => Exception('boom').logException(), returnsNormally);
    });

    test('does not throw for an Object that is neither String nor Exception', () {
      expect(() => 42.logException(), returnsNormally);
    });
  });

  group('printInConsole', () {
    test('does not throw for a String receiver', () {
      expect(() => 'debug message'.printInConsole(), returnsNormally);
    });

    test('does not throw for a non-String receiver (no-op)', () {
      expect(() => 42.printInConsole(), returnsNormally);
    });
  });
}

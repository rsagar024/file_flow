import 'package:flutter/foundation.dart';

extension ObjectExtension on Object {
  void logException() {
    if (this is String) {
      if (kDebugMode) {
        print(this);
      }
    } else if (this is Exception) {
      if (kDebugMode) {
        final error = this as Exception;
        print('\x1B[31m${error.toString()}\x1B[0m');
      }
    }
  }

  void printInConsole() {
    if (this is String) {
      if (kDebugMode) {
        print('DEBUG LOG: $this');
      }
    }
  }
}

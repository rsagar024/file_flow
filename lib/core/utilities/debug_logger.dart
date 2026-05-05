import 'dart:developer';

import 'package:fileflow/core/themes/ansi_color_code.dart';
import 'package:flutter/foundation.dart';

void printInfo(String text) {
  if (kDebugMode) debugPrint(AnsiColorsCode.blue + text + AnsiColorsCode.normal);
}

void printWarning(String text) {
  if (kDebugMode) debugPrint(AnsiColorsCode.orange + text + AnsiColorsCode.normal);
}

void printError(String text) {
  if (kDebugMode) debugPrint(AnsiColorsCode.red + text + AnsiColorsCode.normal);
}

void printSuccess(String text) {
  if (kDebugMode) debugPrint(AnsiColorsCode.green + text + AnsiColorsCode.normal);
}

void printDebug(String text) {
  if (kDebugMode) debugPrint(text + AnsiColorsCode.normal);
}

void logInfo(String text) {
  if (kDebugMode) log(AnsiColorsCode.blue + text + AnsiColorsCode.normal);
}

void logWarning(String text) {
  if (kDebugMode) log(AnsiColorsCode.orange + text + AnsiColorsCode.normal);
}

void logError(String text) {
  if (kDebugMode) log(AnsiColorsCode.red + text + AnsiColorsCode.normal);
}

void logSuccess(String text) {
  if (kDebugMode) log(AnsiColorsCode.green + text + AnsiColorsCode.normal);
}

void logDebug(String text) {
  if (kDebugMode) log(text + AnsiColorsCode.normal);
}

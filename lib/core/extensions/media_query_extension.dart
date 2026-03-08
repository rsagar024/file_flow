import 'package:flutter/material.dart';

extension MediaQueryExtension on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get topPadding => MediaQuery.of(this).padding.top;

  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  double get viewInsetsBottom => MediaQuery.of(this).viewInsets.bottom;

  bool get bottomPaddingZero => bottomPadding == 0.0;

  double heightPercentage(double percent) => screenHeight * (percent / 100);

  double widthPercentage(double percent) => screenWidth * (percent / 100);
}
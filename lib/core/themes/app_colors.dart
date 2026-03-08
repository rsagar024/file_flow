import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const primary = Color(0xFFD9519D);
  static const secondary = Color(0xFFED8770);
  static const accent = Color(0xFFE1914B);

  // Neutral Colors - Dark Theme
  static const background = Color(0xFF0F172A); // Slate 900
  static const surface = Color(0xFF1E293B); // Slate 800
  static const surfaceLight = Color(0xFF334155); // Slate 700

  // Gray Scale
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFE2E8F0);
  static const neutral200 = Color(0xFFCBD5E1);
  static const neutral300 = Color(0xFF94A3B8);
  static const neutral400 = Color(0xFF64748B);

  static const black = Color(0xFF000000);

  // Semantic Colors
  static const success = Color(0xFF10B981); // Emerald
  static const warning = Color(0xFFF59E0B); // Amber
  static const error = Color(0xFFEF4444); // Red
  static const info = Color(0xFF0EA5E9); // Sky

  // Gradient Collections
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, background],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x40FFFFFF), // White with opacity
      Color(0x10FFFFFF), // White with opacity
    ],
  );

  // Overlay Colors
  static const overlay20 = Color(0x33000000); // Black with 20% opacity
  static const overlay40 = Color(0x66000000); // Black with 40% opacity
  static const overlay60 = Color(0x99000000); // Black with 60% opacity

  // Glass Effect Colors
  static const glassLight = Color(0x0DFFFFFF); // White with 5% opacity
  static const glassMedium = Color(0x1AFFFFFF); // White with 10% opacity
  static const glassDark = Color(0x26FFFFFF); // White with 15% opacity
}

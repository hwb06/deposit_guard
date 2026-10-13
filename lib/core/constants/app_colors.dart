import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryLight = Color(0xFF8AB4FF);

  // Status
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE0A100);
  static const Color danger = Color(0xFFD64545);

  // Light theme
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF14181F);
  static const Color lightTextSecondary = Color(0xFF5B6472);
  static const Color lightBorder = Color(0xFFE3E6EB);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F1216);
  static const Color darkSurface = Color(0xFF181C22);
  static const Color darkTextPrimary = Color(0xFFF1F3F6);
  static const Color darkTextSecondary = Color(0xFF9AA3B2);
  static const Color darkBorder = Color(0xFF2A3038);
}
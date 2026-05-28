import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgPrimary = Color(0xFF0D1117);
  static const Color bgCard = Color(0xFF161B22);
  static const Color bgCardLight = Color(0xFF1C2333);
  static const Color bgInput = Color(0xFF1A1F2E);
  static const Color bgNavBar = Color(0xFF0F1318);

  // Accent — Yellow
  static const Color accent = Color(0xFFF5C518);
  static const Color accentDark = Color(0xFFD4A80F);
  static const Color accentLight = Color(0x33F5C518);

  // Purple
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFF9F67FF);
  static const Color purpleBg = Color(0x337C3AED);

  // Semantic
  static const Color green = Color(0xFF22C55E);
  static const Color greenBg = Color(0x3322C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color redBg = Color(0x33EF4444);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeBg = Color(0x33F97316);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Border
  static const Color border = Color(0xFF2D333B);
  static const Color borderLight = Color(0xFF21262D);

  // Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, Color(0xFFEAB308)],
  );
}

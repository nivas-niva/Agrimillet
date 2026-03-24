import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2E7D32); // Deep Green
  static const Color accent = Color(0xFF4CAF50);  // Glow Green
  
  // Dark Theme Palette
  static const Color background = Color(0xFF0F1711); // Very Deep charcoal with green hint
  static const Color surface = Color(0xFF1B261D);    // Slightly lighter charcoal-green
  static const Color surfaceLight = Color(0xFF253328);
  static const Color shadowDark = Color(0xFF070B08);
  static const Color shadowLight = Color(0xFF2B3D2F);
  
  // Glassmorphic Palette
  static Color glassBackground = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textAccent = Color(0xFF81C784);
}

class AppDecorations {
  static BoxDecoration neumorphic({
    Color? color,
    double borderRadius = 16,
    bool pressed = false,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: pressed
          ? [
              BoxShadow(
                color: AppColors.shadowDark,
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: AppColors.shadowLight,
                offset: const Offset(-1, -1),
                blurRadius: 2,
              ),
            ]
          : [
              const BoxShadow(
                color: AppColors.shadowDark,
                offset: Offset(6, 6),
                blurRadius: 12,
              ),
              const BoxShadow(
                color: AppColors.shadowLight,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
    );
  }

  static BoxDecoration glass({
    double borderRadius = 16,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassBorder, width: 1.5),
    );
  }
}

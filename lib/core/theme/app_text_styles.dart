import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.beVietnamPro(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => GoogleFonts.beVietnamPro(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.beVietnamPro(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get label => GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get chatBubble => GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get chatBubbleWhite => GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.surfaceWhite,
      );

  // White variants for teal backgrounds
  static TextStyle get displayWhite => display.copyWith(color: AppColors.surfaceWhite);
  static TextStyle get h1White => h1.copyWith(color: AppColors.surfaceWhite);
  static TextStyle get h2White => h2.copyWith(color: AppColors.surfaceWhite);
  static TextStyle get bodyWhite => body.copyWith(color: AppColors.surfaceWhite);
  static TextStyle get labelWhite => label.copyWith(color: AppColors.surfaceWhite);
  static TextStyle get captionWhite => caption.copyWith(color: Colors.white70);
}

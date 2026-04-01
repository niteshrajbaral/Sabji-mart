import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system using DM Serif Display (headings) + DM Sans (body).
/// Single source of truth — never define TextStyles inline.
abstract final class AppTextStyles {
  // ─── Heading / Serif ────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get headlineMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get headlineSmall => GoogleFonts.dmSerifDisplay(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get titleLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
        letterSpacing: 0.5,
      );

  // ─── Body / Sans ────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.5,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        letterSpacing: 0.3,
      );

  static TextStyle get price => GoogleFonts.dmSerifDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get priceLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get buttonPrimary => GoogleFonts.dmSerifDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.cream,
        letterSpacing: 0.5,
      );

  static TextStyle get navLabel => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
      );
}

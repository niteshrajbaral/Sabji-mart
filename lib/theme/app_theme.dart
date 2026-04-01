import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_text_styles.dart';

/// Material theme wiring all brand tokens.
final class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.darkBrown,
          onPrimary: AppColors.cream,
          secondary: AppColors.caramel,
          onSecondary: AppColors.white,
          tertiary: AppColors.caramel,
          onTertiary: AppColors.white,
          surface: AppColors.warmWhite,
          onSurface: AppColors.text,
          onSurfaceVariant: AppColors.textLight,
          error: AppColors.terracotta,
          outline: AppColors.beige,
          secondaryContainer: AppColors.softBrown,
          onSecondaryContainer: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelMedium: AppTextStyles.label,
          labelSmall: AppTextStyles.labelSmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.darkBrown),
          titleTextStyle: AppTextStyles.headlineLarge,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBrown,
            foregroundColor: AppColors.cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusL),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: AppTextStyles.buttonPrimary,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkBrown,
            side: const BorderSide(color: AppColors.darkBrown, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.softBrown,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusS),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.darkBrown;
              }
              return AppColors.beige;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.cream;
              return AppColors.softBrown;
            }),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.darkBrown;
              }
              return AppColors.beige;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.cream;
              return AppColors.softBrown;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDecorations.radiusML)),
            ),
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.darkBrown;
              }
              return AppColors.beige;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.cream;
              return AppColors.softBrown;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDecorations.radiusS)),
            ),
            side: const WidgetStatePropertyAll(BorderSide.none),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            borderSide: const BorderSide(color: AppColors.beige, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            borderSide: const BorderSide(color: AppColors.beige, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusM),
            borderSide: const BorderSide(color: AppColors.caramel, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
        ),
        dividerColor: AppColors.beige,
        dividerTheme: const DividerThemeData(
          color: AppColors.beige,
          thickness: 1,
          space: 0,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppDecorations.radiusCard)),
            side: BorderSide(color: AppColors.beige),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.softBrown,
          labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusSM),
            side: BorderSide.none,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDecorations.radiusCard)),
          ),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          AppThemeExtension(
            productImageGradient: AppColors.productImageGradient,
            primaryGradient: AppColors.primaryGradient,
            heroGradient: AppColors.heroGradient,
          ),
        ],
      );
}

/// Custom theme extension for properties not supported by default ThemeData.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Gradient productImageGradient;
  final Gradient primaryGradient;
  final Gradient heroGradient;

  const AppThemeExtension({
    required this.productImageGradient,
    required this.primaryGradient,
    required this.heroGradient,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Gradient? productImageGradient,
    Gradient? primaryGradient,
    Gradient? heroGradient,
  }) {
    return AppThemeExtension(
      productImageGradient: productImageGradient ?? this.productImageGradient,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
      covariant ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      productImageGradient:
          Gradient.lerp(productImageGradient, other.productImageGradient, t)!,
      primaryGradient:
          Gradient.lerp(primaryGradient, other.primaryGradient, t)!,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
    );
  }
}

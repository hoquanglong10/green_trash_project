import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF2563EB);
  static const amber = Color(0xFFF59E0B);
  static const purple = Color(0xFF8B5CF6);
  static const slate = Color(0xFF1F2937);
  static const gray = Color(0xFFF3F4F6);
  static const white = Color(0xFFFFFFFF);

  static const jungleGreen = green;
  static const bahia = amber;
  static const corduroy = slate;
  static const azure = gray;

  static const primary = green;
  static const primaryDark = slate;
  static const primaryLight = Color(0x1A10B981);
  static const secondary = blue;
  static const secondaryLight = Color(0x1A2563EB);
  static const deepGreen = slate;
  static const accent = amber;
  static const accentLight = Color(0x1AF59E0B);
  static const support = purple;
  static const supportLight = Color(0x1A8B5CF6);
  static const corduroyLight = Color(0x1A1F2937);

  static const screenBackground = gray;
  static const surface = white;
  static const surfaceAlt = gray;
  static const mint = Color(0x1A10B981);
  static const border = Color(0x1F1F2937);
  static const borderLight = Color(0x141F2937);

  static const text = slate;
  static const muted = Color(0xCC1F2937);
  static const textMuted = Color(0x991F2937);
  static const textInverse = white;
  static const textInverseMuted = Color(0xCCFFFFFF);

  static const success = green;
  static const warning = amber;
  static const error = amber;

  static Color opacity(Color color, double value) {
    // ignore: deprecated_member_use
    return color.withOpacity(value);
  }
}

class HomeTrialColors {
  const HomeTrialColors._();

  static const green = AppColors.green;
  static const blue = AppColors.blue;
  static const amber = AppColors.amber;
  static const purple = AppColors.purple;
  static const slate = AppColors.slate;
  static const gray = AppColors.gray;
  static const white = AppColors.white;

  static const greenSoft = AppColors.primaryLight;
  static const blueSoft = AppColors.secondaryLight;
  static const amberSoft = AppColors.accentLight;
  static const purpleSoft = AppColors.supportLight;
  static const slateSoft = AppColors.borderLight;
  static const border = AppColors.border;
  static const muted = AppColors.textMuted;
}

class AuthRefColors {
  const AuthRefColors._();

  static const controlText = AppColors.textMuted;
  static const controlIcon = AppColors.textMuted;
  static const controlSurface = AppColors.gray;
  static const controlSelectedSurface = AppColors.borderLight;
  static const controlBorder = AppColors.border;
  static const controlSelectedBorder = AppColors.border;
  static const linkBlue = AppColors.blue;

  static const googleBlue = Color(0xFF4285F4);
  static const googleRed = Color(0xFFEA4335);
  static const googleYellow = Color(0xFFFBBC05);
  static const googleGreen = Color(0xFF34A853);
  static const facebookBlue = Color(0xFF1877F2);
}

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double screenHorizontal = 16;
  static const double authScreenHorizontal = 24;
  static const double homeScreenHorizontal = 12;
  static const double sectionGap = 20;
  static const double fieldGap = 14;
  static const double labelInputGap = 6;
  static const double buttonTopGap = 20;
}

class AppRadius {
  const AppRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;
  static const double pill = 999;
}

class AppSizes {
  const AppSizes._();

  static const double appHeaderHeight = 56;
  static const double headerIconSize = 22;
  static const double inputHeight = 46;
  static const double buttonHeight = 46;
  static const double socialButtonHeight = 44;
  static const double cardRadius = AppRadius.lg;
  static const double promoCardRadius = AppRadius.xl;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.support,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    const textTheme = TextTheme(
      headlineSmall: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleMedium: TextStyle(
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        color: AppColors.text,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        color: AppColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        color: AppColors.muted,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        color: AppColors.text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      labelMedium: TextStyle(
        color: AppColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      labelSmall: TextStyle(
        color: AppColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.screenBackground,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSizes.appHeaderHeight,
        iconTheme: IconThemeData(color: AppColors.textInverse, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.textInverse, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.textInverse,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              minimumSize: const Size(48, AppSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.opacity(AppColors.accent, 0.22);
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.opacity(AppColors.accent, 0.14);
                }
                return null;
              }),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, AppSizes.buttonHeight),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.3),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceAlt,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.text),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textInverse,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

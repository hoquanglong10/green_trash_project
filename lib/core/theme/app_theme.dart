import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

class AppColors {
  const AppColors._();

  static const green50 = Color(0xFFF0F5F2);
  static const green100 = Color(0xFFDCE9E1);
  static const green200 = Color(0xFFB9D2C2);
  static const green300 = Color(0xFF8DB49C);
  static const green400 = Color(0xFF5F9275);
  static const green500 = Color(0xFF3E765A);
  static const green600 = Color(0xFF285F46);
  static const green700 = Color(0xFF1F4D3A);
  static const green800 = Color(0xFF173D2F);
  static const green900 = Color(0xFF102F25);
  static const green950 = Color(0xFF091E18);
  static const primaryHover = Color(0xFF214F3B);

  static const yellow50 = Color(0xFFFFFAE8);
  static const yellow100 = Color(0xFFFFF3C4);
  static const yellow200 = Color(0xFFFFE484);
  static const yellow400 = Color(0xFFF4C430);
  static const yellow500 = Color(0xFFDFAE10);
  static const yellow700 = Color(0xFF8A5A00);

  static const botanicalDark = green900;
  static const botanicalDeep = green600;
  static const botanicalMid = green500;
  static const botanicalSage = green300;
  static const botanicalMist = green200;
  static const botanicalCanvas = green50;
  static const neutralGray = Color(0xFFF4F6F4);
  static const brandAccent = Color(0xFFF4C430);
  static const accentForeground = yellow700;
  static const white = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFEAEEEB);
  static const neutralBorder = Color(0xFFD9DFDA);
  static const neutralDivider = Color(0xFFC6CEC8);
  static const textPrimary = Color(0xFF16221C);
  static const textSecondary = Color(0xFF536159);
  static const textTertiary = Color(0xFF7A867F);

  static const processing = Color(0xFF245EA8);
  static const processingLight = Color(0xFFE8F1FF);
  static const successGreen = Color(0xFF26733A);
  static const successLight = Color(0xFFE3F5E8);
  static const danger = Color(0xFFB7382E);
  static const dangerLight = Color(0xFFFDE9E7);

  // Compatibility aliases keep existing screens on semantic V2 roles.
  static const green = botanicalDeep;
  static const greenDeep = botanicalDark;
  static const greenBright = botanicalMid;
  static const blue = processing;
  static const lime = botanicalMid;
  static const amber = brandAccent;
  static const purple = botanicalMid;
  static const coral = danger;
  static const slate = textPrimary;
  static const gray = neutralGray;

  static const jungleGreen = green;
  static const bahia = amber;
  static const corduroy = slate;
  static const azure = gray;

  static const primary = green;
  static const primaryDark = greenDeep;
  static const primaryLight = green100;
  static const secondary = blue;
  static const secondaryLight = processingLight;
  static const deepGreen = greenDeep;
  static const accent = amber;
  static const accentLight = yellow100;
  static const support = purple;
  static const supportLight = green50;
  static const limeLight = green200;
  static const errorLight = dangerLight;
  static const corduroyLight = surfaceSubtle;

  static const screenBackground = neutralGray;
  static const surface = white;
  static const surfaceAlt = surfaceSubtle;
  static const surfaceElevated = white;
  static const mint = green100;
  static const border = neutralBorder;
  static const borderLight = neutralBorder;
  static const divider = neutralDivider;

  static const text = textPrimary;
  static const muted = textSecondary;
  static const textMuted = textTertiary;
  static const textInverse = white;
  static const textInverseMuted = Color(0xCCFFFFFF);

  static const success = successGreen;
  static const warning = accentForeground;
  static const error = danger;

  static Color opacity(Color color, double value) {
    // ignore: deprecated_member_use
    return color.withOpacity(value);
  }
}

class AppGradients {
  const AppGradients._();

  static const appBar = LinearGradient(
    colors: [AppColors.white, AppColors.white],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const hero = LinearGradient(
    colors: [AppColors.green900, AppColors.green700],
    stops: [0, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const success = LinearGradient(
    colors: [AppColors.green600, AppColors.green600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  const AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x0F102013), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const raised = [
    BoxShadow(color: Color(0x14102013), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const hero = [
    BoxShadow(color: Color(0x1F102013), blurRadius: 12, offset: Offset(0, 5)),
  ];

  static const topBar = [
    BoxShadow(color: Color(0x1A18351B), blurRadius: 20, offset: Offset(0, -6)),
  ];
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
  static const controlIcon = AppColors.primaryDark;
  static const controlSurface = AppColors.gray;
  static const controlSelectedSurface = AppColors.primaryLight;
  static const controlBorder = AppColors.border;
  static const controlSelectedBorder = AppColors.primary;
  static const linkBlue = AppColors.primary;

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
  static const double homeScreenHorizontal = 16;
  static const double sectionGap = 24;
  static const double fieldGap = 14;
  static const double labelInputGap = 6;
  static const double buttonTopGap = 20;
}

class AppRadius {
  const AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 22;
  static const double pill = 999;
}

class AppSizes {
  const AppSizes._();

  static const double appHeaderHeight = 64;
  static const double headerIconSize = 23;
  static const double inputHeight = 50;
  static const double buttonHeight = 50;
  static const double socialButtonHeight = 48;
  static const double compactControlHeight = 38;
  static const double timeSlotChipWidth = 128;
  static const double cardRadius = AppRadius.xl;
  static const double promoCardRadius = 18;
}

class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration stagger = Duration(milliseconds: 55);
  static const Curve emphasized = Curves.easeOutCubic;
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
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
      ),
      titleLarge: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
      ),
      titleMedium: TextStyle(
        color: AppColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.38,
      ),
      titleSmall: TextStyle(
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        color: AppColors.muted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      bodyMedium: TextStyle(
        color: AppColors.muted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      labelMedium: TextStyle(
        color: AppColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
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
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.green900,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSizes.appHeaderHeight,
        iconTheme: IconThemeData(color: AppColors.green900, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.green900, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        shape: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              disabledBackgroundColor: AppColors.divider,
              disabledForegroundColor: AppColors.textMuted,
              minimumSize: const Size(48, AppSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.green700;
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primaryHover;
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
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
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
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceAlt,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.text),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textInverse,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: const Color(0x2418351B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorShape: const RoundedRectangleBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryDark
                : AppColors.textMuted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
            size: 22,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceAlt,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceAlt;
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

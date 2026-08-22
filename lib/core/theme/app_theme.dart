import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// DuoMate's design system.
///
/// Visual direction: clean, iOS-native feel — soft neutral backgrounds,
/// a single confident accent color, generous spacing, rounded corners,
/// and San-Francisco-like typography (Plus Jakarta Sans, since Apple's
/// SF Pro isn't licensed for redistribution).
class AppColors {
  AppColors._();

  // Brand accent — a fresh teal-blue, distinct from Duolingo's green
  // and from plain iOS blue, so DuoMate has its own identity.
  static const Color primary = Color(0xFF3B82F6); // vivid azure
  static const Color primaryDark = Color(0xFF60A5FA);

  static const Color success = Color(0xFF34C759); // iOS green
  static const Color warning = Color(0xFFFF9F0A); // iOS orange
  static const Color danger = Color(0xFFFF3B30); // iOS red

  // Light mode surfaces
  static const Color bgLight = Color(0xFFF2F2F7); // iOS grouped bg
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF6B6B70);
  static const Color separatorLight = Color(0xFFE5E5EA);

  // Dark mode surfaces
  static const Color bgDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color textDark = Color(0xFFF2F2F7);
  static const Color textSecondaryDark = Color(0xFF9B9BA1);
  static const Color separatorDark = Color(0xFF38383A);
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color base, Color secondary) {
    final font = GoogleFonts.plusJakartaSansTextTheme();
    return font.copyWith(
      displaySmall: font.displaySmall?.copyWith(
          fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
      headlineMedium: font.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700, color: base, letterSpacing: -0.3),
      titleLarge: font.titleLarge
          ?.copyWith(fontWeight: FontWeight.w600, color: base),
      titleMedium: font.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: base),
      bodyLarge: font.bodyLarge?.copyWith(color: base, height: 1.4),
      bodyMedium: font.bodyMedium?.copyWith(color: secondary, height: 1.4),
      labelLarge: font.labelLarge
          ?.copyWith(fontWeight: FontWeight.w600, color: base),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.success,
      surface: AppColors.surfaceLight,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: _textTheme(AppColors.textLight, AppColors.textSecondaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme(AppColors.textLight, AppColors.textSecondaryLight)
            .headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.separatorLight, thickness: 0.6, space: 0.6),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.success,
      surface: AppColors.surfaceDark,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: _textTheme(AppColors.textDark, AppColors.textSecondaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme(AppColors.textDark, AppColors.textSecondaryDark)
            .headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.separatorDark, thickness: 0.6, space: 0.6),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

/// A reusable iOS-style "grouped list" card wrapper used across
/// Home, Vocabulary, and Settings for that native-feeling layout.
class IosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const IosCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: child,
    );
  }
}

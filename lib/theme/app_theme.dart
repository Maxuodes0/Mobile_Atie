import 'package:flutter/material.dart';

class AppTheme {
  static const String primaryFontFamily = 'LouisGeorgeCafe';
  static const List<String> currencyFontFallback = ['AiteSaudiRiyal'];
  static const String dashboardFontFamily = primaryFontFamily;

  // Matches the web app's palette:
  // - Dashboard pages: bg #f7f7f8, cards #fff, text #0f1115
  // - Public pages: warm beige background (#f6e4d3) + beige gradients
  static const Color ink = Color(0xFF171716);
  static const Color primary = Color(0xFF171716);
  static const Color accent = Color(0xFF3F403D);
  static const Color pageBg = Color(0xFFF2F2F0);
  static const Color landingBg = Color(0xFFF6E4D3);
  static const Color surface = Color(0xFFFEFEFD);
  static const Color border = Color(0xFFD9D9D5);
  static const Color muted = Color(0xFF5F605C);
  static const Color softSurface = Color(0xFFE8E8E5);
  static const Color chartTrack = Color(0xFFD7D7D3);

  // Editorial dashboard palette. Kept separate from the shared application
  // palette so this visual direction can be evaluated on the dashboard first.
  static const Color dashboardCanvas = Color(0xFFD5D4D1);
  static const Color dashboardPaper = Color(0xFFF7F7F3);
  static const Color dashboardMint = Color(0xFF89B5A5);
  static const Color dashboardGraphite = Color(0xFF7B7B77);
  static const Color dashboardInk = Color(0xFF080808);
  static const Color dashboardMuted = Color(0xFF8B8B87);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: primaryFontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: pageBg,
    );

    final fontTheme = base.textTheme.apply(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: currencyFontFallback,
    );
    final textTheme = fontTheme
        .copyWith(
          displayLarge: fontTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
          ),
          headlineLarge: fontTheme.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
          headlineMedium: fontTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          titleLarge: fontTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
          titleMedium: fontTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          titleSmall: fontTheme.titleSmall?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          bodyLarge: fontTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: fontTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
          bodySmall: fontTheme.bodySmall?.copyWith(
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
          labelLarge: fontTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          labelMedium: fontTheme.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          labelSmall: fontTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        )
        .apply(
          bodyColor: ink,
          displayColor: ink,
        )
        .apply(fontFamilyFallback: currencyFontFallback);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: pageBg,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: primaryFontFamily,
          fontFamilyFallback: currencyFontFallback,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme:
          const DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: ink),
        ),
        hintStyle: const TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: const TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacitySafe(0.08),
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: ink,
            fontFamily: primaryFontFamily,
            fontFamilyFallback: currencyFontFallback,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected) ? ink : muted;
          return IconThemeData(color: color);
        }),
      ),
    );
  }
}

extension ColorOpacitySafe on Color {
  // Flutter 3.38 deprecates `Color.withOpacity` due to precision loss. This keeps call sites readable.
  Color withOpacitySafe(double opacity) {
    final o = opacity.clamp(0.0, 1.0);
    return withAlpha((o * 255).round());
  }
}

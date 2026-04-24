import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Matches the web app's palette:
  // - Dashboard pages: bg #f7f7f8, cards #fff, text #0f1115
  // - Public pages: warm beige background (#f6e4d3) + beige gradients
  static const Color ink = Color(0xFF0F1115);
  static const Color primary = Color(0xFF111827);
  static const Color accent = Color(0xFF4F9E8D);
  static const Color pageBg = Color(0xFFF7F7F8);
  static const Color landingBg = Color(0xFFF6E4D3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF6B7280);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
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

    return base.copyWith(
      textTheme: GoogleFonts.tajawalTextTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pageBg,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme:
          const DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary),
        ),
        hintStyle: const TextStyle(color: muted, fontSize: 13),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacitySafe(0.08),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.tajawalTextTheme(base.textTheme).labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ink,
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

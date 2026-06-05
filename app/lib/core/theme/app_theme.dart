import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// NUMINA theme. Exposes Material 3 [ThemeData] for both light and dark
/// modes plus a [NuminaThemeExt] extension carrying our richer palette.
class AppTheme {
  AppTheme._();

  /// UI font for English (Geist isn't on Google Fonts yet — Inter is the
  /// closest modern geometric sans-serif and matches Geist's metrics well).
  static TextStyle uiText({Color? color, double size = 14, FontWeight w = FontWeight.w400}) =>
      GoogleFonts.inter(color: color, fontSize: size, fontWeight: w, letterSpacing: -0.1);

  /// UI font for Arabic.
  static TextStyle arText({Color? color, double size = 14, FontWeight w = FontWeight.w400}) =>
      GoogleFonts.ibmPlexSansArabic(color: color, fontSize: size, fontWeight: w);

  /// Mono font for the calculator display + numbers.
  static TextStyle monoText({Color? color, double size = 14, FontWeight w = FontWeight.w400, double letter = -0.5}) =>
      GoogleFonts.jetBrainsMono(color: color, fontSize: size, fontWeight: w, letterSpacing: letter);

  /// Picks the right font family for the current locale.
  static TextStyle uiFor(Locale locale, {Color? color, double size = 14, FontWeight w = FontWeight.w400}) {
    return locale.languageCode == 'ar'
        ? arText(color: color, size: size, w: w)
        : uiText(color: color, size: size, w: w);
  }

  static ThemeData light() => _build(NuminaPalette.light);
  static ThemeData dark() => _build(NuminaPalette.dark);

  static ThemeData _build(NuminaPalette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: p.isDark ? Brightness.dark : Brightness.light,
      primary: p.accent,
      onPrimary: p.accentInk,
      surface: p.surface,
      onSurface: p.text,
      error: p.danger,
    );

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: scheme.brightness).textTheme,
    ).apply(bodyColor: p.text, displayColor: p.text);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: p.text,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.accentInk,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: p.textDim, size: 20),
      dividerColor: p.border,
      splashFactory: InkSparkle.splashFactory,
      extensions: [NuminaThemeExt(p)],
    );
  }
}

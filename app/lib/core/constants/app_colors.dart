import 'package:flutter/material.dart';

/// NUMINA design tokens. Mirrored from `SCwAI/tokens.jsx` so the
/// Flutter app stays a 1:1 visual port of the design system.
class NuminaColors {
  NuminaColors._();

  // Brand greens
  static const brand50  = Color(0xFFE9FBF3);
  static const brand100 = Color(0xFFC8F3DF);
  static const brand200 = Color(0xFF8FE6BF);
  static const brand300 = Color(0xFF4FD49A);
  static const brand400 = Color(0xFF1FBF7D);
  static const brand500 = Color(0xFF0AA46A); // primary (light)
  static const brand600 = Color(0xFF068557);
  static const brand700 = Color(0xFF066647);
  static const brand800 = Color(0xFF054E38);
  static const brand900 = Color(0xFF053A2B);
  static const brand950 = Color(0xFF02201A);
}

/// A flat record-style theme palette so widgets can grab tokens with
/// `context.numina.surface` etc. without going through Material's
/// `ColorScheme` (which doesn't have enough slots for our needs).
class NuminaPalette {
  final Color bg;
  final Color bgRaised;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textDim;
  final Color textMute;
  final Color accent;
  final Color accentSoft;
  final Color danger;
  final Color warn;
  final Color op;
  final Color keyBg;
  final Color keyBgAlt;
  final Color keyText;
  final Color glass;
  final Color aurora1;
  final Color aurora2;
  final bool isDark;

  const NuminaPalette({
    required this.bg,
    required this.bgRaised,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textDim,
    required this.textMute,
    required this.accent,
    required this.accentSoft,
    required this.danger,
    required this.warn,
    required this.op,
    required this.keyBg,
    required this.keyBgAlt,
    required this.keyText,
    required this.glass,
    required this.aurora1,
    required this.aurora2,
    required this.isDark,
  });

  static const light = NuminaPalette(
    bg:           Color(0xFFF4F6F3),
    bgRaised:     Color(0xFFFFFFFF),
    surface:      Color(0xFFFFFFFF),
    surface2:     Color(0xFFEEF1EC),
    border:       Color(0x14141E19),     // rgba(20,30,25,0.08)
    borderStrong: Color(0x24141E19),     // rgba(20,30,25,0.14)
    text:         Color(0xFF0D1612),
    textDim:      Color(0xFF475651),
    textMute:     Color(0xFF7D8A85),
    accent:       NuminaColors.brand500,
    accentSoft:   NuminaColors.brand50,
    danger:       Color(0xFFD14A3B),
    warn:         Color(0xFFC98A1E),
    op:           NuminaColors.brand500,
    keyBg:        Color(0xFFFFFFFF),
    keyBgAlt:     Color(0xFFE8ECE6),
    keyText:      Color(0xFF0D1612),
    glass:        Color(0xB3FFFFFF),     // rgba(255,255,255,0.7)
    aurora1:      Color(0x1F0AA46A),     // rgba(10,164,106,0.12)
    aurora2:      Color(0x1A32C8AA),     // rgba(50,200,170,0.10)
    isDark:       false,
  );

  static const dark = NuminaPalette(
    bg:           Color(0xFF06100C),
    bgRaised:     Color(0xFF0C1A14),
    surface:      Color(0xFF0F201A),
    surface2:     Color(0xFF15291F),
    border:       Color(0x1A78C8AA),     // rgba(120,200,170,0.10)
    borderStrong: Color(0x3378C8AA),     // rgba(120,200,170,0.20)
    text:         Color(0xFFEAF6F0),
    textDim:      Color(0xFF9AB5AA),
    textMute:     Color(0xFF5E7A72),
    accent:       Color(0xFF3FE09A),
    accentSoft:   Color(0x243FE09A),     // rgba(63,224,154,0.14)
    danger:       Color(0xFFFF7A6B),
    warn:         Color(0xFFFFC14F),
    op:           Color(0xFF3FE09A),
    keyBg:        Color(0xFF15291F),
    keyBgAlt:     Color(0xFF1C3528),
    keyText:      Color(0xFFEAF6F0),
    glass:        Color(0x990F201A),     // rgba(15,32,26,0.6)
    aurora1:      Color(0x2E3FE09A),     // rgba(63,224,154,0.18)
    aurora2:      Color(0x2428B4C8),     // rgba(40,180,200,0.14)
    isDark:       true,
  );

  Color get accentInk => isDark ? const Color(0xFF03130C) : Colors.white;
}

/// Theme-extension wrapper so widgets can do `Theme.of(context).extension<NuminaPalette>()`.
class NuminaThemeExt extends ThemeExtension<NuminaThemeExt> {
  final NuminaPalette palette;
  const NuminaThemeExt(this.palette);

  @override
  NuminaThemeExt copyWith({NuminaPalette? palette}) =>
      NuminaThemeExt(palette ?? this.palette);

  @override
  NuminaThemeExt lerp(ThemeExtension<NuminaThemeExt>? other, double t) =>
      this; // no animation needed; instant theme swap is fine
}

extension NuminaPaletteAccess on BuildContext {
  NuminaPalette get numina =>
      Theme.of(this).extension<NuminaThemeExt>()!.palette;
}

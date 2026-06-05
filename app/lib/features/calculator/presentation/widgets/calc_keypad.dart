import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum KeyKind { digit, op, fn, alt, mute, equals }

class CalcKey {
  final String label;
  final KeyKind kind;
  final String? token;
  const CalcKey(this.label, this.kind, {this.token});
}

class CalcKeyButton extends StatelessWidget {
  const CalcKeyButton({
    super.key,
    required this.k,
    required this.onTap,
    this.fontSize,
  });

  final CalcKey k;
  final VoidCallback onTap;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final (Color bg, Color fg, Color border, List<BoxShadow> shadow) =
        switch (k.kind) {
      KeyKind.digit => (p.keyBg, p.keyText, p.border, const <BoxShadow>[]),
      KeyKind.alt => (p.keyBgAlt, p.keyText, p.border, const <BoxShadow>[]),
      KeyKind.op => (p.accentSoft, p.accent, Colors.transparent, const <BoxShadow>[]),
      KeyKind.fn => (p.surface, p.text, p.border, const <BoxShadow>[]),
      KeyKind.mute => (Colors.transparent, p.textDim, p.border, const <BoxShadow>[]),
      KeyKind.equals => (
        p.accent,
        p.accentInk,
        Colors.transparent,
        [
          BoxShadow(
            color: p.accent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    };

    final isShortLabel = k.label.length <= 2;
    final size = fontSize ?? (isShortLabel ? 22.0 : 13.0);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: border, width: 0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: shadow,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                k.label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: size,
                  fontWeight:
                      k.kind == KeyKind.equals ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalcKeypad extends StatelessWidget {
  const CalcKeypad({
    super.key,
    required this.shift,
    required this.scientific,
    required this.onShiftToggle,
    required this.onTap,
    required this.onClear,
    required this.onBackspace,
    required this.onEquals,
    required this.onToggleSign,
    required this.onMemoryClear,
    required this.onMemoryAdd,
    required this.onMemorySubtract,
    required this.onMemoryRecall,
    required this.onRandom,
    required this.onAngleToggle,
  });

  final bool shift;
  final bool scientific;
  final VoidCallback onShiftToggle;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onEquals;
  final VoidCallback onToggleSign;
  final VoidCallback onMemoryClear;
  final VoidCallback onMemoryAdd;
  final VoidCallback onMemorySubtract;
  final VoidCallback onMemoryRecall;
  final VoidCallback onRandom;
  final VoidCallback onAngleToggle;

  @override
  Widget build(BuildContext context) {
    // ─── iOS-style sci layout: 5 rows × 6 cols ─────────────────────────
    //   Row 1: ( ) mc m+ m- mr
    //   Row 2: 2ⁿᵈ x² x³ xʸ eˣ 10ˣ      (shift swaps row 2 & 3 to hyperbolic)
    //   Row 3: ¹⁄ₓ ²√x ³√x ʸ√x ln log₁₀
    //   Row 4: x! sin cos tan e EE
    //   Row 5: Rand sinh cosh tanh π Deg
    final sciRows = shift
        ? const [
            ['(', ')',  'mc', 'm+', 'm-', 'mr'],
            ['2ⁿᵈ', 'sinh⁻¹(', 'cosh⁻¹(', 'tanh⁻¹(', 'eˣ', '10ˣ'],
            ['¹⁄ₓ', '²√x', '³√x', 'ʸ√x', 'ln', 'log₁₀'],
            ['x!', 'sin⁻¹(', 'cos⁻¹(', 'tan⁻¹(', 'e', 'EE'],
            ['Rand', 'sinh', 'cosh', 'tanh', 'π', 'Deg'],
          ]
        : const [
            ['(', ')',  'mc', 'm+', 'm-', 'mr'],
            ['2ⁿᵈ', 'x²', 'x³', 'xʸ', 'eˣ', '10ˣ'],
            ['¹⁄ₓ', '²√x', '³√x', 'ʸ√x', 'ln', 'log₁₀'],
            ['x!', 'sin', 'cos', 'tan', 'e', 'EE'],
            ['Rand', 'sinh', 'cosh', 'tanh', 'π', 'Deg'],
          ];

    // ─── iOS-style numpad: 5 rows × 4 cols ─────────────────────────────
    const numRows = [
      ['⌫', 'C',   '%', '÷'],
      ['7',  '8',  '9', '×'],
      ['4',  '5',  '6', '−'],
      ['1',  '2',  '3', '+'],
      ['±',  '0',  '.', '='],
    ];

    const rowHeight = 44.0;
    Widget flexRow(List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: SizedBox(
          height: rowHeight,
          child: Row(children: children),
        ),
      );
    }

    Widget sep() => const SizedBox(width: 6);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Column(
        children: [
          if (scientific) ...[
            for (final row in sciRows)
              flexRow([
                for (final label in row) ...[
                  Expanded(child: _sciKey(label)),
                  if (label != row.last) sep(),
                ],
              ]),
            const SizedBox(height: 2),
          ],
          for (final row in numRows)
            flexRow([
              for (final label in row) ...[
                Expanded(child: _numKey(label)),
                if (label != row.last) sep(),
              ],
            ]),
        ],
      ),
    );
  }

  Widget _sciKey(String label) {
    // Special keys with custom handlers.
    if (label == '2ⁿᵈ') {
      return CalcKeyButton(
        k: CalcKey('2ⁿᵈ', shift ? KeyKind.equals : KeyKind.mute),
        onTap: onShiftToggle,
        fontSize: 14,
      );
    }
    if (label == 'mc') {
      return CalcKeyButton(
        k: const CalcKey('mc', KeyKind.alt),
        onTap: onMemoryClear,
        fontSize: 14,
      );
    }
    if (label == 'm+') {
      return CalcKeyButton(
        k: const CalcKey('m+', KeyKind.alt),
        onTap: onMemoryAdd,
        fontSize: 14,
      );
    }
    if (label == 'm-') {
      return CalcKeyButton(
        k: const CalcKey('m-', KeyKind.alt),
        onTap: onMemorySubtract,
        fontSize: 14,
      );
    }
    if (label == 'mr') {
      return CalcKeyButton(
        k: const CalcKey('mr', KeyKind.alt),
        onTap: onMemoryRecall,
        fontSize: 14,
      );
    }
    if (label == 'Rand') {
      return CalcKeyButton(
        k: const CalcKey('Rand', KeyKind.alt),
        onTap: onRandom,
        fontSize: 13,
      );
    }
    if (label == 'Deg') {
      return CalcKeyButton(
        k: const CalcKey('Deg', KeyKind.alt),
        onTap: onAngleToggle,
        fontSize: 14,
      );
    }

    // Token-mapped keys.
    final token = _tokenFor(label);
    return CalcKeyButton(
      k: CalcKey(label, KeyKind.alt, token: token),
      onTap: () => onTap(token),
      fontSize: label.length <= 2 ? 18 : 13,
    );
  }

  Widget _numKey(String label) {
    switch (label) {
      case '⌫':
        return CalcKeyButton(
          k: const CalcKey('⌫', KeyKind.mute),
          onTap: onBackspace,
        );
      case 'C':
        return CalcKeyButton(
          k: const CalcKey('C', KeyKind.mute),
          onTap: onClear,
        );
      case '±':
        return CalcKeyButton(
          k: const CalcKey('±', KeyKind.alt),
          onTap: onToggleSign,
          fontSize: 20,
        );
      case '=':
        return CalcKeyButton(
          k: const CalcKey('=', KeyKind.equals),
          onTap: onEquals,
        );
    }
    final isOp = const ['+', '−', '×', '÷'].contains(label);
    final tok = switch (label) {
      '×' => '*',
      '÷' => '/',
      '−' => '-',
      _ => label,
    };
    return CalcKeyButton(
      k: CalcKey(label, isOp ? KeyKind.op : KeyKind.digit, token: tok),
      onTap: () => onTap(tok),
    );
  }

  static String _tokenFor(String label) {
    return switch (label) {
      'x²' => '^2',
      'x³' => '^3',
      'xʸ' => '^',
      '²√x' => 'sqrt(',
      '³√x' => 'cbrt(',
      'ʸ√x' => 'root(',
      '¹⁄ₓ' => '^-1',
      'eˣ' => 'exp(',
      '10ˣ' => '10^',
      'sin' => 'sin(',
      'cos' => 'cos(',
      'tan' => 'tan(',
      'sinh' => 'sinh(',
      'cosh' => 'cosh(',
      'tanh' => 'tanh(',
      'sin⁻¹(' => 'asin(',
      'cos⁻¹(' => 'acos(',
      'tan⁻¹(' => 'atan(',
      'sinh⁻¹(' => 'asinh(',
      'cosh⁻¹(' => 'acosh(',
      'tanh⁻¹(' => 'atanh(',
      'ln' => 'ln(',
      'log₁₀' => 'log10(',
      'EE' => 'E',
      'x!' => '!',
      'π' => 'π',
      'e' => 'e',
      _ => label,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/angle_mode.dart';
import 'calculator_controller.dart';
import 'widgets/calc_keypad.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key, this.onOpenAi});

  final VoidCallback? onOpenAi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(calculatorControllerProvider);
    final ctl = ref.read(calculatorControllerProvider.notifier);
    final t = AppLocalizations.of(context)!;
    final p = context.numina;

    return Column(
      children: [
        _ChipsRow(
          angle: s.angle,
          scientific: s.scientific,
          onAngle: ctl.setAngle,
          onScientific: ctl.toggleScientific,
          labels: (deg: t.deg, rad: t.rad),
        ),
        Expanded(
          child: _Display(state: s, errorLabel: t.errorInvalidExpression),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
          child: _AiButton(
            label: 'Solve with AI',
            onPressed: onOpenAi,
            ink: p.accentInk,
          ),
        ),
        CalcKeypad(
          shift: s.shift,
          scientific: s.scientific,
          onShiftToggle: ctl.toggleShift,
          onTap: ctl.append,
          onClear: ctl.clear,
          onBackspace: ctl.backspace,
          onEquals: ctl.equals,
          onToggleSign: ctl.toggleSign,
          onMemoryClear: ctl.memoryClear,
          onMemoryAdd: ctl.memoryAdd,
          onMemorySubtract: ctl.memorySubtract,
          onMemoryRecall: ctl.memoryRecall,
          onRandom: ctl.insertRandom,
          onAngleToggle: ctl.toggleAngleMode,
        ),
      ],
    );
  }
}

typedef _Labels = ({String deg, String rad});

class _ChipsRow extends StatelessWidget {
  const _ChipsRow({
    required this.angle,
    required this.scientific,
    required this.onAngle,
    required this.onScientific,
    required this.labels,
  });

  final AngleMode angle;
  final bool scientific;
  final ValueChanged<AngleMode> onAngle;
  final VoidCallback onScientific;
  final _Labels labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: Row(
        children: [
          // DEG / RAD pill
          _SegmentedPill(
            options: [
              (label: labels.deg, selected: angle == AngleMode.degrees, onTap: () => onAngle(AngleMode.degrees)),
              (label: labels.rad, selected: angle == AngleMode.radians, onTap: () => onAngle(AngleMode.radians)),
            ],
          ),
          const SizedBox(width: 8),
          // Basic / Sci pill
          _SegmentedPill(
            options: [
              (label: 'Basic', selected: !scientific, onTap: scientific ? onScientific : () {}),
              (label: 'Sci',   selected: scientific,  onTap: !scientific ? onScientific : () {}),
            ],
          ),
        ],
      ),
    );
  }
}

typedef _SegOption = ({String label, bool selected, VoidCallback onTap});

class _SegmentedPill extends StatelessWidget {
  const _SegmentedPill({required this.options});
  final List<_SegOption> options;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((o) => _ModeChip(text: o.label, selected: o.selected, onTap: o.onTap))
            .toList(),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? p.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: selected ? p.accentInk : p.textDim,
          ),
        ),
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.state, required this.errorLabel});
  final CalcState state;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final showCommitted = state.committedResult != null && state.liveResult == null;
    final result = state.error != null
        ? errorLabel
        : (state.liveResult != null ? '= ${state.liveResult}' : (showCommitted ? '= ${state.committedResult}' : ''));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Expression line + blinking caret
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    state.expression.isEmpty ? ' ' : state.expression,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: p.text,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                _BlinkingCaret(color: p.accent),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              result.isEmpty ? ' ' : result,
              textAlign: TextAlign.end,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 44,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
                height: 1,
                color: state.error != null ? p.danger : p.accent,
                shadows: p.isDark && state.error == null
                    ? [
                        Shadow(
                          color: p.accent.withValues(alpha: 0.30),
                          blurRadius: 30,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret({required this.color});
  final Color color;

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, _) => Opacity(
        opacity: _ctl.value < 0.5 ? 1 : 0,
        child: Container(width: 2, height: 28, color: widget.color),
      ),
    );
  }
}

class _AiButton extends StatelessWidget {
  const _AiButton({
    required this.label,
    required this.onPressed,
    required this.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.accent, p.isDark ? const Color(0xFF1EC98A) : const Color(0xFF0D8A5A)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: p.isDark ? 0.35 : 0.30),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: ink, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

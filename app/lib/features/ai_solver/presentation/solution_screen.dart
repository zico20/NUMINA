import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/numina_logo.dart';
import '../../graphing/presentation/graphing_screen.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/history_entry.dart';
import '../domain/solve_result.dart';

/// Full-screen solution view shown after the camera flow finishes
/// analyzing. Renders Problem / Answer / Steps cards with quick action
/// buttons (Graph / Copy LaTeX / Save) and a Quick/Step-by-step view
/// toggle that filters client-side (no extra API call).
class SolutionScreen extends ConsumerStatefulWidget {
  const SolutionScreen({super.key, required this.result});
  final SolveResult result;

  @override
  ConsumerState<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends ConsumerState<SolutionScreen> {
  /// Visible mode — controls only what the UI shows (steps shown vs. hidden).
  /// The data was already fetched in detailed mode.
  SolveMode _viewMode = SolveMode.detailed;
  bool _saved = false;
  bool _sharing = false;

  /// Boundary wrapping the rendered cards so we can rasterize them for the
  /// image-based share flow.
  final _shareBoundary = GlobalKey();

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _shareBoundary.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Render boundary not ready');
      }
      // 3x for crisp shareable resolution.
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw StateError('toByteData returned null');
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/numina_solution_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png', name: 'solution.png')],
        text: 'Solved with NUMINA',
      );
    } catch (_) {
      // Fallback: share plain text if image capture fails.
      final r = widget.result;
      Share.share(
        'Problem: ${r.latex}\nAnswer: ${r.answer}\n\nSolved with NUMINA',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _copyLatex() {
    Clipboard.setData(ClipboardData(text: widget.result.answer));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('LaTeX copied'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    if (_saved) return;
    final repo = ref.read(historyRepositoryProvider);
    final r = widget.result;
    await repo.add(HistoryEntry(
      expression: r.latex.isEmpty ? '(image)' : r.latex,
      result: r.answer,
      createdAt: DateTime.now(),
      pinned: true,
      latex: r.answer,
      // Encoded full result so History can reopen this in SolutionScreen.
      aiResultJson: jsonEncode(r.toJson()),
    ));
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to history'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _graph() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GraphingScreen(
        initialExpression: _latexToPlot(widget.result.answer),
      ),
    ));
  }

  /// Best-effort LaTeX → plot expression. Strips common LaTeX wrappers and
  /// keeps the parts our calc engine understands. Far from perfect, but
  /// good enough for typical answers like `\ln|x|`, `2x+3`, `x^2`.
  String _latexToPlot(String latex) {
    return latex
        .replaceAll(r'\ln', 'ln')
        .replaceAll(r'\log', 'log')
        .replaceAll(r'\sin', 'sin')
        .replaceAll(r'\cos', 'cos')
        .replaceAll(r'\tan', 'tan')
        .replaceAll(r'\sqrt', 'sqrt')
        .replaceAll(r'\pi', 'pi')
        .replaceAllMapped(RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
            (m) => '(${m[1]})/(${m[2]})')
        .replaceAll('|x|', 'abs(x)')
        .replaceAll(RegExp(r'\\[a-zA-Z]+'), '')
        .replaceAll('{', '(')
        .replaceAll('}', ')')
        .trim();
  }

  bool get _answerLooksLikeFunction =>
      widget.result.answer.contains('x') ||
      widget.result.answer.contains('y');

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final r = widget.result;
    final hasSteps = r.steps.isNotEmpty;

    return Scaffold(
      backgroundColor: p.bg,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar — back + title + share
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    NuminaTopButton(
                      icon: Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r.isMath ? 'Solution' : 'AI Solver',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ),
                    if (r.isMath)
                      NuminaTopButton(
                        icon: Icons.ios_share,
                        onPressed: _share,
                      ),
                  ],
                ),
              ),
              if (r.isMath && hasSteps)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _ViewModePill(
                    mode: _viewMode,
                    onChanged: (m) => setState(() => _viewMode = m),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    RepaintBoundary(
                      key: _shareBoundary,
                      // Solid bg so the captured PNG isn't transparent.
                      child: ColoredBox(
                        color: p.bg,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _ResultBody(
                            result: r,
                            viewMode: _viewMode,
                            saved: _saved,
                            onGraph: _answerLooksLikeFunction ? _graph : null,
                            onCopy: _copyLatex,
                            onSave: _save,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModePill extends StatelessWidget {
  const _ViewModePill({required this.mode, required this.onChanged});
  final SolveMode mode;
  final ValueChanged<SolveMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Expanded(child: _seg(context, SolveMode.quick, 'Quick', Icons.bolt)),
          Expanded(child: _seg(context, SolveMode.detailed, 'Step-by-step', Icons.menu_book_outlined)),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, SolveMode value, String label, IconData icon) {
    final p = context.numina;
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: selected ? p.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: selected ? p.accentInk : p.textDim),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? p.accentInk : p.textDim,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.result,
    required this.viewMode,
    required this.saved,
    required this.onGraph,
    required this.onCopy,
    required this.onSave,
  });

  final SolveResult result;
  final SolveMode viewMode;
  final bool saved;
  final VoidCallback? onGraph;
  final VoidCallback onCopy;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;

    if (!result.isMath) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.warn.withValues(alpha: 0.40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: p.warn.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.info_outline, size: 18, color: p.warn),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Math problems only',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              result.refusal.isNotEmpty
                  ? result.refusal
                  : 'I only solve math problems. Please send a math equation.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: p.textDim,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Problem card with confidence badge
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Label('PROBLEM', muted: true),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 1, color: p.border)),
                  const SizedBox(width: 10),
                  _ConfidenceBadge(value: result.confidence),
                ],
              ),
              const SizedBox(height: 10),
              _Math(tex: result.latex, fontSize: 22),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Answer card with action buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [p.accentSoft, p.surface],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: p.accent),
                  const SizedBox(width: 8),
                  Text(
                    'ANSWER',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: p.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Math(tex: result.answer, fontSize: 24),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.show_chart,
                      label: 'Graph',
                      onTap: onGraph,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.copy_outlined,
                      label: 'Copy LaTeX',
                      onTap: onCopy,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ActionButton(
                      icon: saved ? Icons.bookmark : Icons.bookmark_border,
                      label: saved ? 'Saved' : 'Save',
                      onTap: saved ? null : onSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (viewMode == SolveMode.detailed && result.steps.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Label('STEP-BY-STEP', muted: true),
          const SizedBox(height: 8),
          ...result.steps.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: p.accentSoft,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${e.key + 1}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: p.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.value.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: p.isDark
                            ? Colors.black.withValues(alpha: 0.30)
                            : const Color(0xFFF4F7F3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: p.border),
                      ),
                      child: _Math(tex: e.value.latex, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final (Color color, String label) = value >= 80
        ? (p.accent, 'High confidence')
        : value >= 50
            ? (p.warn, 'Medium confidence')
            : (p.danger, 'Low confidence');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label · $value%',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Material(
        color: p.bgRaised,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
            ),
            child: Column(
              children: [
                Icon(icon, size: 18, color: p.text),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.muted = false});
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: muted ? p.textMute : p.text,
      ),
    );
  }
}

class _Math extends StatelessWidget {
  const _Math({required this.tex, this.fontSize = 18});
  final String tex;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    if (tex.trim().isEmpty) return const SizedBox.shrink();
    final math = Math.tex(
      tex,
      textStyle: TextStyle(fontSize: fontSize, color: p.text),
      mathStyle: MathStyle.display,
      onErrorFallback: (_) => Text(
        tex,
        style: GoogleFonts.jetBrainsMono(fontSize: fontSize, color: p.text),
      ),
    );
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 80,
          ),
          child: Center(child: math),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/numina_logo.dart';
import '../../calculator/domain/angle_mode.dart';
import '../../calculator/domain/calc_engine.dart';
import '../../calculator/presentation/calculator_controller.dart';

/// One function on the graph.
class _GraphFn {
  final String expression;
  final Color color;
  List<FlSpot>? points; // computed lazily on plot
  bool valid = true;

  _GraphFn({required this.expression, required this.color});
}

class GraphingScreen extends ConsumerStatefulWidget {
  const GraphingScreen({super.key, this.initialExpression});

  final String? initialExpression;

  @override
  ConsumerState<GraphingScreen> createState() => _GraphingScreenState();
}

class _GraphingScreenState extends ConsumerState<GraphingScreen> {
  /// Palette used to colour successive functions; cycles when exhausted.
  static const _palette = <Color>[
    Color(0xFF3FE09A), // brand accent (dark)
    Color(0xFFFF7A6B), // danger red
    Color(0xFF6BB8FF), // soft blue
    Color(0xFFFFC14F), // amber
    Color(0xFFD17AFF), // purple
  ];

  static const _xMin = -10.0;
  static const _xMax = 10.0;

  late List<_GraphFn> _fns;
  final _shareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExpression?.trim().isNotEmpty == true
        ? widget.initialExpression!
        : 'sin(x)';
    _fns = [_GraphFn(expression: initial, color: _palette[0])];
    WidgetsBinding.instance.addPostFrameCallback((_) => _plotAll());
  }

  void _plotAll() {
    final engine = ref.read(calcEngineProvider);
    for (final fn in _fns) {
      _plotOne(fn, engine);
    }
    if (mounted) setState(() {});
  }

  void _plotOne(_GraphFn fn, CalcEngine engine) {
    final src = fn.expression;
    final spots = <FlSpot>[];
    var ok = true;
    for (var x = _xMin; x <= _xMax; x += 0.05) {
      try {
        final substituted = src.replaceAll('x', '($x)');
        final y = engine.evaluate(substituted, angle: AngleMode.radians);
        if (y.isFinite) spots.add(FlSpot(x, y));
      } on FormatException {
        ok = false;
        break;
      }
    }
    fn.points = ok ? spots : null;
    fn.valid = ok;
  }

  Future<void> _addFunction() async {
    final result = await _editFunction(null);
    if (result == null || result.trim().isEmpty) return;
    final color = _palette[_fns.length % _palette.length];
    final fn = _GraphFn(expression: result.trim(), color: color);
    _plotOne(fn, ref.read(calcEngineProvider));
    setState(() => _fns.add(fn));
  }

  Future<void> _editAt(int index) async {
    final fn = _fns[index];
    final updated = await _editFunction(fn.expression);
    if (updated == null) return;
    if (updated.trim().isEmpty) {
      // Empty input → delete
      setState(() => _fns.removeAt(index));
      return;
    }
    final newFn = _GraphFn(expression: updated.trim(), color: fn.color);
    _plotOne(newFn, ref.read(calcEngineProvider));
    setState(() => _fns[index] = newFn);
  }

  Future<String?> _editFunction(String? initial) async {
    final p = context.numina;
    final ctrl = TextEditingController(text: initial ?? '');
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Text(
              initial == null ? 'Add function' : 'Edit function',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: p.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Text(
                    'f(x) =',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 15,
                      color: p.textDim,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      autofocus: true,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'sin(x) + 0.5*x',
                        hintStyle: GoogleFonts.jetBrainsMono(
                          fontSize: 15,
                          color: p.textMute,
                        ),
                      ),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 15,
                        color: p.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (initial != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(sheetCtx, ''),
                      icon: Icon(Icons.delete_outline, color: p.danger, size: 18),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.inter(color: p.danger, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: p.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (initial != null) const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetCtx, ctrl.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: p.accentInk,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      initial == null ? 'Add' : 'Save',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share() async {
    try {
      final boundary = _shareKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/numina_graph_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png', name: 'graph.png')],
        text: 'Plotted with NUMINA',
      );
    } catch (_) {
      // best-effort; silently ignore share failures
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final p = context.numina;
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
                        t.tabGraphing,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ),
                    NuminaTopButton(
                      icon: Icons.ios_share,
                      onPressed: _fns.any((f) => f.points != null) ? _share : null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    // Plot card (wrapped in RepaintBoundary so we can share it).
                    RepaintBoundary(
                      key: _shareKey,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: p.isDark ? const Color(0xFF08130E) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: p.border),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _PlotChart(
                            fns: _fns,
                            xMin: _xMin,
                            xMax: _xMax,
                            isDark: p.isDark,
                            border: p.border,
                            textMute: p.textMute,
                            textDim: p.textDim,
                            errorLabel: t.errorInvalidExpression,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Function rows
                    for (var i = 0; i < _fns.length; i++) ...[
                      _FnRow(
                        fn: _fns[i],
                        onTap: () => _editAt(i),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Add button
                    _AddFunctionButton(onTap: _addFunction),
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

class _PlotChart extends StatelessWidget {
  const _PlotChart({
    required this.fns,
    required this.xMin,
    required this.xMax,
    required this.isDark,
    required this.border,
    required this.textMute,
    required this.textDim,
    required this.errorLabel,
  });

  final List<_GraphFn> fns;
  final double xMin;
  final double xMax;
  final bool isDark;
  final Color border;
  final Color textMute;
  final Color textDim;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    final hasAnyValid = fns.any((f) => f.points != null && f.points!.isNotEmpty);
    if (fns.isEmpty || !hasAnyValid) {
      return Center(
        child: Text(
          fns.isEmpty ? 'Tap "+ Add function"' : errorLabel,
          style: GoogleFonts.inter(color: textMute),
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          for (final fn in fns)
            if (fn.points != null && fn.points!.isNotEmpty)
              LineChartBarData(
                spots: fn.points!,
                isCurved: true,
                dotData: const FlDotData(show: false),
                barWidth: 2.5,
                color: fn.color,
                shadow: isDark
                    ? Shadow(color: fn.color.withValues(alpha: 0.6), blurRadius: 8)
                    : const Shadow(color: Colors.transparent),
              ),
        ],
        minX: xMin,
        maxX: xMax,
        clipData: const FlClipData.all(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: textMute),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: textMute),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => FlLine(color: border, strokeWidth: 0.5),
          getDrawingVerticalLine: (_) => FlLine(color: border, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [HorizontalLine(y: 0, color: textDim, strokeWidth: 1)],
          verticalLines: [VerticalLine(x: 0, color: textDim, strokeWidth: 1)],
        ),
      ),
    );
  }
}

class _FnRow extends StatelessWidget {
  const _FnRow({required this.fn, required this.onTap});
  final _GraphFn fn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              // Color marker
              Container(
                width: 8,
                height: 28,
                decoration: BoxDecoration(
                  color: fn.color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: p.isDark
                      ? [BoxShadow(color: fn.color.withValues(alpha: 0.6), blurRadius: 12)]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: ClipRect(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Math.tex(
                        'f(x)=${fn.expression}',
                        textStyle: TextStyle(fontSize: 16, color: p.text),
                        mathStyle: MathStyle.text,
                        onErrorFallback: (_) => Text(
                          'f(x) = ${fn.expression}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            color: p.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                fn.valid ? Icons.tune : Icons.error_outline,
                size: 18,
                color: fn.valid ? p.textMute : p.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddFunctionButton extends StatelessWidget {
  const _AddFunctionButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: DottedBorderBox(
        color: p.border,
        radius: 14,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: p.textDim),
              const SizedBox(width: 6),
              Text(
                'Add function',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple dashed-border box. Avoids adding a `dotted_border` dependency
/// for one-off use.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color, width: 1.5),
      ),
      child: child,
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../ai_solver/domain/solve_result.dart';
import '../../ai_solver/presentation/solution_screen.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';

final historyStreamProvider = StreamProvider<List<HistoryEntry>>((ref) {
  return ref.watch(historyRepositoryProvider).watch();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyStreamProvider);
    final repo = ref.read(historyRepositoryProvider);
    final t = AppLocalizations.of(context)!;
    final p = context.numina;

    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 48, color: p.textMute),
                const SizedBox(height: 12),
                Text(
                  t.noHistory,
                  style: GoogleFonts.inter(fontSize: 14, color: p.textDim),
                ),
              ],
            ),
          );
        }
        final groups = _groupByDay(items);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.tabHistory,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: () => repo.clearAll(),
                    style: TextButton.styleFrom(
                      foregroundColor: p.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: p.border),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final g in groups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  g.label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: p.textMute,
                  ),
                ),
              ),
              ...g.items.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _HistoryRow(
                      entry: e,
                      onPin: () => repo.togglePin(e),
                      onDelete: () => repo.delete(e),
                      onTap: e.isAi ? () => _openAiResult(context, e) : null,
                    ),
                  )),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  void _openAiResult(BuildContext context, HistoryEntry e) {
    try {
      final json = jsonDecode(e.aiResultJson!) as Map<String, dynamic>;
      final result = SolveResult.fromJson(json);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SolutionScreen(result: result)),
      );
    } catch (_) {
      // Stored format is bad — fail soft.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved entry is corrupted')),
      );
    }
  }
}

class _Group {
  final String label;
  final List<HistoryEntry> items;
  _Group(this.label, this.items);
}

List<_Group> _groupByDay(List<HistoryEntry> items) {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  final t = <HistoryEntry>[];
  final y = <HistoryEntry>[];
  final older = <HistoryEntry>[];
  for (final e in items) {
    if (sameDay(e.createdAt, today)) {
      t.add(e);
    } else if (sameDay(e.createdAt, yesterday)) {
      y.add(e);
    } else {
      older.add(e);
    }
  }
  return [
    if (t.isNotEmpty) _Group('Today', t),
    if (y.isNotEmpty) _Group('Yesterday', y),
    if (older.isNotEmpty) _Group('Earlier', older),
  ];
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.onPin,
    required this.onDelete,
    this.onTap,
  });

  final HistoryEntry entry;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    final isAi = entry.isAi;
    return Dismissible(
      key: ValueKey('hist-${entry.createdAt.microsecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: p.danger.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline, color: p.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isAi ? p.accentSoft : p.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isAi ? Icons.auto_awesome : Icons.functions,
                    size: 16,
                    color: isAi ? p.accent : p.textDim,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Expr(text: entry.expression, isAi: isAi),
                      const SizedBox(height: 2),
                      _Result(text: entry.result, isAi: isAi),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            DateFormat.Hm().format(entry.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: p.textMute,
                            ),
                          ),
                          if (isAi) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: p.accentSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'AI',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: p.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPin,
                  splashRadius: 18,
                  icon: Icon(
                    entry.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 16,
                    color: entry.pinned ? p.accent : p.textMute,
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

/// Renders an expression/LaTeX string. For AI entries we attempt
/// `Math.tex`; on parse error we fall back to mono text. Calculator
/// entries always show as mono text.
class _Expr extends StatelessWidget {
  const _Expr({required this.text, required this.isAi});
  final String text;
  final bool isAi;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    if (!isAi) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(fontSize: 14, color: p.text),
      );
    }
    return SizedBox(
      height: 26,
      child: ClipRect(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Math.tex(
            text,
            textStyle: TextStyle(fontSize: 16, color: p.text),
            mathStyle: MathStyle.text,
            onErrorFallback: (_) => Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(fontSize: 14, color: p.text),
            ),
          ),
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.text, required this.isAi});
  final String text;
  final bool isAi;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    if (!isAi) {
      return Text(
        '= $text',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(fontSize: 13, color: p.accent),
      );
    }
    return Row(
      children: [
        Text('= ', style: GoogleFonts.jetBrainsMono(fontSize: 13, color: p.accent)),
        Flexible(
          child: SizedBox(
            height: 22,
            child: ClipRect(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Math.tex(
                  text,
                  textStyle: TextStyle(fontSize: 14, color: p.accent),
                  mathStyle: MathStyle.text,
                  onErrorFallback: (_) => Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(fontSize: 13, color: p.accent),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

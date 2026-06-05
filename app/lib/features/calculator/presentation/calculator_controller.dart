import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/angle_mode.dart';
import '../domain/calc_engine.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/history_entry.dart';

class CalcState {
  final String expression;
  final String? liveResult;   // continuously updated as user types
  final String? committedResult; // last `=` result (also goes to history)
  final String? lastAns;       // for ANS button
  final String? error;
  final AngleMode angle;
  final bool shift;            // 2nd-function toggle (sci pad row swap)
  final bool scientific;       // sci pad visible vs basic-only
  final double memory;         // M+/M-/MR/MC accumulator

  const CalcState({
    this.expression = '',
    this.liveResult,
    this.committedResult,
    this.lastAns,
    this.error,
    this.angle = AngleMode.degrees,
    this.shift = false,
    this.scientific = false,
    this.memory = 0,
  });

  CalcState copyWith({
    String? expression,
    String? liveResult,
    String? committedResult,
    String? lastAns,
    String? error,
    AngleMode? angle,
    bool? shift,
    bool? scientific,
    double? memory,
    bool clearError = false,
    bool clearLive = false,
  }) {
    return CalcState(
      expression: expression ?? this.expression,
      liveResult: clearLive ? null : (liveResult ?? this.liveResult),
      committedResult: committedResult ?? this.committedResult,
      lastAns: lastAns ?? this.lastAns,
      error: clearError ? null : (error ?? this.error),
      angle: angle ?? this.angle,
      shift: shift ?? this.shift,
      scientific: scientific ?? this.scientific,
      memory: memory ?? this.memory,
    );
  }
}

class CalculatorController extends StateNotifier<CalcState> {
  CalculatorController(this._engine, this._history) : super(const CalcState());

  final CalcEngine _engine;
  final HistoryRepository _history;

  void _evalLive(String expr) {
    if (expr.trim().isEmpty) {
      state = state.copyWith(clearLive: true, clearError: true);
      return;
    }
    try {
      // Substitute Ans before evaluating live.
      final sub = state.lastAns == null
          ? expr
          : expr.replaceAll('Ans', '(${state.lastAns})');
      final v = _engine.evaluate(sub, angle: state.angle);
      state = state.copyWith(liveResult: _format(v), clearError: true);
    } on FormatException {
      state = state.copyWith(clearLive: true);
    }
  }

  void append(String token) {
    final expr = state.expression + token;
    state = state.copyWith(expression: expr);
    _evalLive(expr);
  }

  void backspace() {
    if (state.expression.isEmpty) return;
    final expr = state.expression.substring(0, state.expression.length - 1);
    state = state.copyWith(expression: expr);
    _evalLive(expr);
  }

  void clear() {
    state = CalcState(
      angle: state.angle,
      shift: state.shift,
      scientific: state.scientific,
      lastAns: state.lastAns,
    );
  }

  void setAngle(AngleMode mode) {
    state = state.copyWith(angle: mode);
    _evalLive(state.expression);
  }

  void toggleShift() => state = state.copyWith(shift: !state.shift);

  void toggleScientific() =>
      state = state.copyWith(scientific: !state.scientific);

  void insertAns() {
    if (state.lastAns != null) append('Ans');
  }

  // ─── Memory ────────────────────────────────────────────────────────────
  /// Returns the current "operand" value to feed into M+/M- — uses the
  /// live result if available, otherwise the committed result, otherwise 0.
  double _currentValue() {
    final src = state.liveResult ?? state.committedResult;
    if (src == null) return 0;
    return double.tryParse(src) ?? 0;
  }

  void memoryClear() => state = state.copyWith(memory: 0);

  void memoryAdd() =>
      state = state.copyWith(memory: state.memory + _currentValue());

  void memorySubtract() =>
      state = state.copyWith(memory: state.memory - _currentValue());

  void memoryRecall() {
    final s = _format(state.memory);
    final expr = state.expression + s;
    state = state.copyWith(expression: expr);
    _evalLive(expr);
  }

  // ─── Other iOS-style helpers ───────────────────────────────────────────
  void insertRandom() {
    final v = math.Random().nextDouble();
    final s = _format(v);
    final expr = state.expression + s;
    state = state.copyWith(expression: expr);
    _evalLive(expr);
  }

  void toggleAngleMode() {
    final next = state.angle == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;
    setAngle(next);
  }

  /// iOS-style ± — flips the sign of the trailing operand.
  void toggleSign() {
    final expr = state.expression;
    if (expr.isEmpty) return;

    // Match the trailing operand: a (-x) wrapper, a -x, or a bare number.
    final m = RegExp(r'(.*?)(\(-[\d.]+\)|-[\d.]+|[\d.]+)$').firstMatch(expr);
    if (m == null) return;
    final prefix = m[1] ?? '';
    var operand = m[2]!;

    if (operand.startsWith('(-') && operand.endsWith(')')) {
      operand = operand.substring(2, operand.length - 1);
    } else if (operand.startsWith('-')) {
      operand = operand.substring(1);
    } else {
      operand = '(-$operand)';
    }
    final next = prefix + operand;
    state = state.copyWith(expression: next);
    _evalLive(next);
  }

  Future<void> equals() async {
    if (state.expression.trim().isEmpty) return;
    try {
      final sub = state.lastAns == null
          ? state.expression
          : state.expression.replaceAll('Ans', '(${state.lastAns})');
      final v = _engine.evaluate(sub, angle: state.angle);
      final formatted = _format(v);
      await _history.add(
        HistoryEntry(
          expression: state.expression,
          result: formatted,
          createdAt: DateTime.now(),
        ),
      );
      state = state.copyWith(
        expression: formatted,
        committedResult: formatted,
        lastAns: formatted,
        clearLive: true,
        clearError: true,
      );
    } on FormatException {
      state = state.copyWith(error: 'invalid', clearLive: true);
    }
  }

  String _format(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    final s = v.toStringAsPrecision(12);
    return s
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

final calcEngineProvider = Provider<CalcEngine>((_) => CalcEngine());

final calculatorControllerProvider =
    StateNotifierProvider<CalculatorController, CalcState>((ref) {
  return CalculatorController(
    ref.watch(calcEngineProvider),
    ref.watch(historyRepositoryProvider),
  );
});

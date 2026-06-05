import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'angle_mode.dart';

/// Pure-function math engine. Translates a user-friendly expression
/// (with friendly tokens like √, π, sin) into something math_expressions
/// can parse, then evaluates it under a given [AngleMode].
class CalcEngine {
  CalcEngine();

  static final _parser = GrammarParser();

  /// Returns the numeric result, or throws [FormatException] on bad input.
  double evaluate(String input, {AngleMode angle = AngleMode.radians}) {
    if (input.trim().isEmpty) throw const FormatException('empty');
    final normalized = _normalize(input, angle);
    try {
      final exp = _parser.parse(normalized);
      final ctx = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, ctx);
      if (result is num) {
        if (result.isNaN || result.isInfinite) {
          throw const FormatException('non-finite');
        }
        return result.toDouble();
      }
      throw const FormatException('non-numeric');
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('parse-error');
    }
  }

  String _normalize(String s, AngleMode angle) {
    var out = s
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(',', '.')
        .replaceAll('π', '(${math.pi})');

    // Scientific-notation numbers (`1.5e-3`, `2E5`) → expanded form
    // `(1.5*10^(-3))`. The math_expressions parser doesn't understand
    // bare exponent notation, and substituted plot-loop x values can
    // arrive in this form due to floating-point accumulation.
    out = out.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)[eE]([+-]?\d+)'),
      (m) => '(${m[1]}*10^(${m[2]}))',
    );

    // 'e' as a constant — only when truly standalone (not inside an
    // identifier like `exp`).
    out = out.replaceAllMapped(RegExp(r'(?<![a-zA-Z0-9_.])e(?![a-zA-Z0-9_])'),
        (m) => '(${math.e})');

    out = out.replaceAll('√', 'sqrt');
    out = out.replaceAllMapped(
        RegExp(r'∛\(([^)]+)\)'), (m) => '((${m[1]})^(1/3))');

    // Resolve factorial/cbrt/root/log10 before trig wrapping. Repeat until
    // a fixed point so nested calls are handled.
    while (true) {
      final before = out;
      out = _resolveFactorial(out);
      out = _resolveBalanced(
        out, 'cbrt(',
        (inner) => '((($inner))^(1/3))',
      );
      out = _resolveBalancedTwoArg(
        out, 'root(',
        (a, b) => '((($b))^(1/(($a))))',
      );
      out = _resolveBalancedTwoArg(
        out, 'logb(',
        (a, b) => '(ln(($b))/ln(($a)))',
      );
      // log10(x) → ln(x)/ln(10)
      out = _resolveBalanced(
        out, 'log10(',
        (inner) => '(ln(($inner))/ln(10))',
      );
      // exp(x) → e^x
      out = _resolveBalanced(
        out, 'exp(',
        (inner) => '((${math.e})^($inner))',
      );
      if (out == before) break;
    }

    if (angle == AngleMode.degrees) {
      out = _wrapTrigArgs(out, math.pi / 180);
    } else if (angle == AngleMode.gradians) {
      out = _wrapTrigArgs(out, math.pi / 200);
    }
    return out;
  }

  /// Replaces every `n!` (where `n` is a number or a parenthesised group)
  /// with its factorial value.
  String _resolveFactorial(String s) {
    // First: numeric literal followed by !
    var out = s.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)!'),
      (m) {
        final n = double.parse(m[1]!);
        return _factorial(n).toString();
      },
    );
    // Second: balanced "(...)!" — scan back from each '!' to find a
    // matching paren group.
    while (true) {
      final i = out.indexOf(')!');
      if (i < 0) break;
      var depth = 1;
      var j = i - 1;
      while (j >= 0 && depth > 0) {
        if (out[j] == ')') depth++;
        if (out[j] == '(') depth--;
        if (depth == 0) break;
        j--;
      }
      if (j < 0) break;
      // Recursively normalize inner first; here we just compute its value
      // by re-evaluating once it has been simplified — simplest path:
      // leave the factorial untouched if we can't resolve to a number.
      final inner = out.substring(j + 1, i);
      final num = double.tryParse(inner);
      if (num == null) {
        // Replace just this occurrence by something the parser will reject
        // but keep loop progress; mark with a sentinel and break.
        out = '${out.substring(0, i + 1)}_FACT_ ${out.substring(i + 2)}';
        break;
      }
      out = out.substring(0, j) +
          _factorial(num).toString() +
          out.substring(i + 2);
    }
    return out;
  }

  double _factorial(double n) {
    if (n < 0 || n != n.roundToDouble()) {
      throw const FormatException('bad-factorial');
    }
    var r = 1.0;
    for (var i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }

  /// Replaces every `prefix(...)` (single arg, balanced) using [transform].
  String _resolveBalanced(String s, String prefix, String Function(String) transform) {
    var out = s;
    while (true) {
      final i = out.indexOf(prefix);
      if (i < 0) break;
      final argStart = i + prefix.length;
      var depth = 1;
      var j = argStart;
      while (j < out.length && depth > 0) {
        if (out[j] == '(') depth++;
        if (out[j] == ')') {
          depth--;
          if (depth == 0) break;
        }
        j++;
      }
      if (j >= out.length) break;
      final inner = out.substring(argStart, j);
      out = out.substring(0, i) + transform(inner) + out.substring(j + 1);
    }
    return out;
  }

  /// Same as [_resolveBalanced] but for two-argument calls split on a
  /// top-level `,`.
  String _resolveBalancedTwoArg(String s, String prefix, String Function(String, String) transform) {
    var out = s;
    while (true) {
      final i = out.indexOf(prefix);
      if (i < 0) break;
      final argStart = i + prefix.length;
      var depth = 1;
      var commaPos = -1;
      var j = argStart;
      while (j < out.length && depth > 0) {
        if (out[j] == '(') depth++;
        if (out[j] == ')') {
          depth--;
          if (depth == 0) break;
        }
        if (out[j] == ',' && depth == 1) commaPos = j;
        j++;
      }
      if (j >= out.length || commaPos < 0) break;
      final a = out.substring(argStart, commaPos);
      final b = out.substring(commaPos + 1, j);
      out = out.substring(0, i) + transform(a, b) + out.substring(j + 1);
    }
    return out;
  }

  /// Wraps the argument of forward trig functions sin/cos/tan with `factor * (...)`,
  /// using a balanced-parentheses scan so nested expressions are handled.
  String _wrapTrigArgs(String input, double factor) {
    const targets = ['sin', 'cos', 'tan'];
    var s = input;
    for (final fn in targets) {
      final pattern = RegExp('(?<![a-zA-Z_])$fn\\(');
      final buf = StringBuffer();
      var i = 0;
      while (i < s.length) {
        final m = pattern.matchAsPrefix(s, i);
        if (m == null) {
          buf.write(s[i]);
          i++;
          continue;
        }
        buf.write('$fn(');
        i = m.end;
        var depth = 1;
        final argStart = i;
        while (i < s.length && depth > 0) {
          final c = s[i];
          if (c == '(') depth++;
          if (c == ')') {
            depth--;
            if (depth == 0) break;
          }
          i++;
        }
        final inner = s.substring(argStart, i);
        buf.write('($factor)*($inner)');
        if (i < s.length) {
          buf.write(s[i]);
          i++;
        }
      }
      s = buf.toString();
    }
    return s;
  }
}

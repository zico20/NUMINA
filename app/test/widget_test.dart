import 'package:flutter_test/flutter_test.dart';
import 'package:smart_calc/features/calculator/domain/angle_mode.dart';
import 'package:smart_calc/features/calculator/domain/calc_engine.dart';

void main() {
  final engine = CalcEngine();

  group('CalcEngine', () {
    test('basic arithmetic', () {
      expect(engine.evaluate('2+3*4'), 14);
      expect(engine.evaluate('(2+3)*4'), 20);
      expect(engine.evaluate('10/4'), 2.5);
    });

    test('symbols are normalized', () {
      expect(engine.evaluate('6×7'), 42);
      expect(engine.evaluate('20÷5'), 4);
      expect(engine.evaluate('√(9)'), 3);
    });

    test('pi constant', () {
      final v = engine.evaluate('π');
      expect(v, closeTo(3.14159265, 1e-6));
    });

    test('trig in degrees', () {
      expect(engine.evaluate('sin(30)', angle: AngleMode.degrees),
          closeTo(0.5, 1e-9));
      expect(engine.evaluate('cos(60)', angle: AngleMode.degrees),
          closeTo(0.5, 1e-9));
    });

    test('trig in radians (default)', () {
      expect(engine.evaluate('sin(0)'), 0);
    });

    test('throws on bad input', () {
      expect(() => engine.evaluate('2++'),
          throwsA(isA<FormatException>()));
      expect(() => engine.evaluate(''), throwsA(isA<FormatException>()));
    });

    test('plotting: sin(substituted x) over a range', () {
      // Mirrors what GraphingScreen does at every sample.
      for (var x = -10.0; x <= 10.0; x += 1.0) {
        final substituted = 'sin(x)'.replaceAll('x', '($x)');
        final y = engine.evaluate(substituted, angle: AngleMode.radians);
        expect(y.isFinite, true, reason: 'failed at x=$x ($substituted)');
      }
    });

    test('plotting: real GraphingScreen loop with 0.1 step', () {
      // Reproduce the EXACT loop, including FP-accumulated x values.
      for (var x = -10.0; x <= 10.0; x += 0.1) {
        final substituted = 'sin(x)'.replaceAll('x', '($x)');
        try {
          engine.evaluate(substituted, angle: AngleMode.radians);
        } on FormatException catch (e) {
          fail('FormatException at x=$x → "$substituted": ${e.message}');
        }
      }
    });
  });
}

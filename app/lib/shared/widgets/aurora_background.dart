import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Two soft radial-gradient blobs mirroring `Aurora` from `tokens.jsx`.
/// Cheap to render — no actual blur, just radial gradients.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    this.intensity = 1.0,
    this.child,
  });

  final double intensity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -50,
                  child: _blob(360, p.aurora1.withValues(alpha: p.aurora1.a * intensity)),
                ),
                Positioned(
                  bottom: -80,
                  right: -60,
                  child: _blob(320, p.aurora2.withValues(alpha: p.aurora2.a * intensity)),
                ),
              ],
            ),
          ),
        ),
        ?child,
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

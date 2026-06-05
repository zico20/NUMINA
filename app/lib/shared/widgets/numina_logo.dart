import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Glowing dot + "NUMINA" wordmark used in screen top bars.
class NuminaWordmark extends StatelessWidget {
  const NuminaWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: p.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: p.accent, blurRadius: 12, spreadRadius: 0.5),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'NUMINA',
          style: GoogleFonts.inter(
            color: p.textDim,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// 36×36 ghost/icon button used in the top bar (menu, settings, share, …).
class NuminaTopButton extends StatelessWidget {
  const NuminaTopButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: p.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(child: Icon(icon, color: p.textDim, size: 18)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'aurora_background.dart';
import 'numina_logo.dart';

/// Standard scaffold for any pushed/full-screen NUMINA page.
/// Provides Aurora background, an inset top bar with a back button,
/// optional title and trailing actions, and a scrollable [child] body.
class NuminaPage extends StatelessWidget {
  const NuminaPage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Scaffold(
      backgroundColor: p.bg,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ),
                    for (final a in actions) ...[
                      const SizedBox(width: 8),
                      a,
                    ],
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

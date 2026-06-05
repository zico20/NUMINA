import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class NuminaDrawerItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const NuminaDrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

/// NUMINA-styled side drawer: gradient header with brand identity,
/// then a list of [items]. Use with Scaffold's `drawer` slot.
class NuminaDrawer extends StatelessWidget {
  const NuminaDrawer({
    super.key,
    required this.items,
  });

  final List<NuminaDrawerItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Drawer(
      backgroundColor: p.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Directionality.of(context) == TextDirection.ltr
              ? const Radius.circular(28)
              : Radius.zero,
          left: Directionality.of(context) == TextDirection.rtl
              ? const Radius.circular(28)
              : Radius.zero,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gradient header with brand
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    p.accent,
                    p.isDark ? const Color(0xFF1EC98A) : const Color(0xFF0D8A5A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.30),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.auto_awesome, color: p.accentInk, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NUMINA',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: p.accentInk,
                    ),
                  ),
                  Text(
                    'AI-powered scientific calculator',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: p.accentInk.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Items
            for (final item in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Material(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).maybePop();
                      item.onTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                              color: p.accentSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, size: 18, color: p.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: p.text,
                                  ),
                                ),
                                if (item.subtitle != null) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    item.subtitle!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: p.textMute,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            size: 16,
                            color: p.textMute,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

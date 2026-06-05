import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final ctl = ref.read(settingsControllerProvider.notifier);
    final t = AppLocalizations.of(context)!;
    final p = context.numina;
    final isDark = p.isDark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        // Pro card header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [p.accent, isDark ? const Color(0xFF1EC98A) : const Color(0xFF0D8A5A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: p.accent.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.auto_awesome, size: 24, color: p.accentInk),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUMINA Pro',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: p.accentInk,
                      ),
                    ),
                    Text(
                      'Unlimited AI solves',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: p.accentInk.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: p.accentInk),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _Section(
          title: 'Appearance',
          children: [
            _Row(
              icon: Icons.dark_mode_outlined,
              title: t.settingsTheme,
              subtitle: switch (settings.themeMode) {
                ThemeMode.dark => t.themeDark,
                ThemeMode.light => t.themeLight,
                _ => t.themeSystem,
              },
              trailing: _ThemeCycle(
                mode: settings.themeMode,
                onChanged: ctl.setThemeMode,
              ),
            ),
            _Row(
              icon: Icons.translate,
              title: t.settingsLanguage,
              subtitle: settings.locale?.languageCode == 'ar'
                  ? 'العربية'
                  : settings.locale?.languageCode == 'en'
                      ? 'English'
                      : t.themeSystem,
              trailing: TextButton(
                onPressed: () => _pickLocale(context, ctl, settings),
                style: TextButton.styleFrom(
                  backgroundColor: p.accentSoft,
                  foregroundColor: p.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  settings.locale?.languageCode == 'ar' ? 'EN' : 'AR',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              isLast: true,
            ),
          ],
        ),
        _Section(
          title: 'AI',
          children: [
            _Row(
              icon: Icons.auto_awesome,
              title: 'Model',
              subtitle: 'GPT-4o Vision',
              trailing: Icon(Icons.chevron_right, size: 14, color: p.textMute),
              isLast: true,
            ),
          ],
        ),
        _Section(
          title: 'About',
          children: [
            _Row(
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
              trailing: Icon(Icons.chevron_right, size: 14, color: p.textMute),
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickLocale(
    BuildContext context,
    SettingsController ctl,
    AppSettings current,
  ) async {
    final p = context.numina;
    final picked = await showModalBottomSheet<Locale?>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone_android, color: p.textDim),
              title: const Text('System'),
              onTap: () => Navigator.pop(context, null),
            ),
            ListTile(
              leading: Icon(Icons.language, color: p.textDim),
              title: const Text('English'),
              onTap: () => Navigator.pop(context, const Locale('en')),
            ),
            ListTile(
              leading: Icon(Icons.language, color: p.textDim),
              title: const Text('العربية'),
              onTap: () => Navigator.pop(context, const Locale('ar')),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked == null && current.locale != null) {
      // null could mean "system" OR cancel — treat as cancel here.
      // No-op, but allow explicit "system" picks.
    }
    await ctl.setLocale(picked);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: p.textMute,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : p.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: p.textDim),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: p.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(fontSize: 12, color: p.textMute),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ThemeCycle extends StatelessWidget {
  const _ThemeCycle({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.numina;
    return GestureDetector(
      onTap: () {
        final next = switch (mode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        };
        onChanged(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          switch (mode) {
            ThemeMode.dark => Icons.dark_mode,
            ThemeMode.light => Icons.light_mode,
            _ => Icons.brightness_auto,
          },
          size: 16,
          color: p.accent,
        ),
      ),
    );
  }
}

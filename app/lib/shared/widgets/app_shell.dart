import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../features/ai_solver/presentation/camera_screen.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/graphing/presentation/graphing_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/unit_converter/presentation/converter_screen.dart';
import '../../l10n/app_localizations.dart';
import 'aurora_background.dart';
import 'numina_drawer.dart';
import 'numina_logo.dart';
import 'numina_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _drawerKey = GlobalKey<ScaffoldState>();

  void _push(Widget page, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NuminaPage(title: title, child: page),
      ),
    );
  }

  void _pushAiSolver() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final p = context.numina;

    return Scaffold(
      key: _drawerKey,
      backgroundColor: p.bg,
      drawer: NuminaDrawer(
        items: [
          NuminaDrawerItem(
            icon: Icons.show_chart,
            title: t.tabGraphing,
            subtitle: t.graphingHint,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GraphingScreen()),
            ),
          ),
          NuminaDrawerItem(
            icon: Icons.swap_horiz,
            title: t.tabConverter,
            subtitle: t.converterTitle,
            onTap: () => _push(const ConverterScreen(), t.tabConverter),
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                onMenu: () => _drawerKey.currentState?.openDrawer(),
                onHistory: () => _push(const HistoryScreen(), t.tabHistory),
                onSettings: () => _push(const SettingsScreen(), t.tabSettings),
              ),
              Expanded(
                child: CalculatorScreen(onOpenAi: _pushAiSolver),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onMenu,
    required this.onHistory,
    required this.onSettings,
  });

  final VoidCallback onMenu;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          NuminaTopButton(icon: Icons.menu, onPressed: onMenu),
          const Spacer(),
          const NuminaWordmark(),
          const Spacer(),
          NuminaTopButton(icon: Icons.history, onPressed: onHistory),
          const SizedBox(width: 8),
          NuminaTopButton(icon: Icons.settings_outlined, onPressed: onSettings),
        ],
      ),
    );
  }
}

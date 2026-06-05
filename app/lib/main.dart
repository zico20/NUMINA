import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/history/data/history_repository.dart';
import 'features/history/domain/history_entry.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'l10n/app_localizations.dart';
import 'shared/widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HistoryEntryAdapter());
  final history = await HistoryRepository.open();

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      historyRepositoryProvider.overrideWithValue(history),
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
    child: const SmartCalcApp(),
  ));
}

class SmartCalcApp extends ConsumerWidget {
  const SmartCalcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}

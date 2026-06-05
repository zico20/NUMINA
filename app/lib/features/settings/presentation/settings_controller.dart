import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale? locale; // null => follow system
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale, bool clearLocale = false}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: clearLocale ? null : (locale ?? this.locale),
      );
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;
  static const _kTheme = 'settings.themeMode';
  static const _kLocale = 'settings.locale';

  static AppSettings _load(SharedPreferences p) {
    // First-launch default is dark — NUMINA is designed dark-first.
    final theme = switch (p.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    final loc = p.getString(_kLocale);
    return AppSettings(
      themeMode: theme,
      locale: (loc == null || loc.isEmpty) ? null : Locale(loc),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kTheme, mode.name);
  }

  Future<void> setLocale(Locale? l) async {
    state = state.copyWith(locale: l, clearLocale: l == null);
    if (l == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, l.languageCode);
    }
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main');
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(sharedPrefsProvider));
});

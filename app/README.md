# Smart Calc — Flutter app

See the [top-level README](../README.md) for the full picture. This file
is just the Flutter quickstart.

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=BACKEND_URL=https://your-proxy.example.com
flutter test
```

## Architecture

Clean Architecture, one folder per feature:

```
lib/
├── core/                       Shared utilities, theme, errors, config
├── features/
│   ├── calculator/             Scientific calculator + math engine
│   ├── ai_solver/              GPT-4o Vision client + UI
│   ├── graphing/               fl_chart-based grapher
│   ├── unit_converter/         Length/weight/time/angle/speed
│   ├── history/                Hive persistence + UI
│   └── settings/               Theme + locale
├── shared/widgets/             AppShell (bottom nav)
├── l10n/                       app_en.arb / app_ar.arb
└── main.dart
```

State management is **Riverpod**. The history repository and shared
preferences are injected into the provider scope at startup in
`main.dart`.

## Build-time configuration

Pass via `--dart-define`:

| Var          | Purpose                                        |
|--------------|------------------------------------------------|
| `BACKEND_URL`| Base URL of the proxy server (no trailing `/`) |

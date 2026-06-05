class AppConfig {
  AppConfig._();

  // Pass via --dart-define=BACKEND_URL=https://your-proxy.example.com
  static const backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  static bool get hasBackend => backendUrl.isNotEmpty;
}

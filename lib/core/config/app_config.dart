/// Supplied at build time:
///   --dart-define=ZUNIQ_API_URL=https://your-project.vercel.app
///   --dart-define=ZUNIQ_API_KEY=<same value as APP_TOKEN on the server>
class AppConfig {
  AppConfig._();
  static const apiUrl = String.fromEnvironment('ZUNIQ_API_URL');
  static const apiKey = String.fromEnvironment('ZUNIQ_API_KEY');

  /// apiUrl without trailing slashes.
  static String get apiBase => apiUrl.replaceAll(RegExp(r'/+$'), '');
  static bool get isAiConfigured => apiUrl.isNotEmpty;
  static const maxImageBytes = 15 * 1024 * 1024;
}

class AppConfig {
  // Override per environment:
  // - Production/App Store uses the default URL below.
  // - Staging or local development must pass an explicit `API_BASE_URL`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://full-coding-system-backend.onrender.com',
  );
}

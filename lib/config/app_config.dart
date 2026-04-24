class AppConfig {
  // Override per environment:
  // - iOS Simulator: default `http://localhost:4000`
  // - Physical iPhone: use your Mac LAN IP, e.g. `http://192.168.1.10:4000`
  // - Production: `https://full-coding-system-backend.onrender.com` (or your own domain)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://full-coding-system-backend.onrender.com',
  );
}

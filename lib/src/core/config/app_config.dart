class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://roulette-john-careless.ngrok-free.dev/api/v1',
  );
}

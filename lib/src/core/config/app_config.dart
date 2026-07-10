class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hunter-womanless-freeware.ngrok-free.dev/api/v1',
  );
}

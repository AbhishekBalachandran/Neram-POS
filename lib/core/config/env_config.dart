/// Runtime environment enum.
enum Environment { development, staging, production }

/// Centralized environment configuration.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.enableLogging,
  });

  final Environment environment;
  final String apiBaseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool enableLogging;

  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;

  /// Default development configuration.
  static const EnvConfig dev = EnvConfig(
    environment: Environment.development,
    apiBaseUrl: 'https://dev-api.nerampos.com/v1',
    connectTimeoutMs: 30000,
    receiveTimeoutMs: 30000,
    enableLogging: true,
  );

  /// Default production configuration.
  static const EnvConfig prod = EnvConfig(
    environment: Environment.production,
    apiBaseUrl: 'https://api.nerampos.com/v1',
    connectTimeoutMs: 30000,
    receiveTimeoutMs: 30000,
    enableLogging: false,
  );
}

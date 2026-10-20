import 'package:neram_pos/core/config/env_config.dart';

/// Singleton manager for application runtime settings.
class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  EnvConfig _env = EnvConfig.dev;

  EnvConfig get env => _env;

  void initialize(EnvConfig config) {
    _env = config;
  }
}

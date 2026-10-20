import 'package:dio/dio.dart';
import 'package:neram_pos/core/config/app_config.dart';
import 'package:neram_pos/core/errors/app_exception.dart';
import 'package:neram_pos/core/network/auth_interceptor.dart';
import 'package:neram_pos/core/security/token_manager.dart';
import 'package:neram_pos/core/services/logger_service.dart';

/// Preconfigured HTTP client wrapping Dio with authentication and error handling.
class DioClient {
  DioClient({required TokenManager tokenManager, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.instance.env.apiBaseUrl,
      connectTimeout: Duration(
        milliseconds: AppConfig.instance.env.connectTimeoutMs,
      ),
      receiveTimeout: Duration(
        milliseconds: AppConfig.instance.env.receiveTimeoutMs,
      ),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      AuthInterceptor(tokenManager: tokenManager, dio: _dio),
      if (AppConfig.instance.env.enableLogging)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (log) => LoggerService.debug(log.toString()),
        ),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;

  /// Helper to convert [DioException] into domain-level [AppException].
  AppException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return NetworkException(
          message:
              'Network connection timed out. Please check your internet connectivity.',
          code: error.type.name,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        final message =
            _extractErrorMessage(responseData) ??
            error.response?.statusMessage ??
            'Server responded with status $statusCode';

        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          responseData: responseData,
        );
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );
      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate verification failed.',
          code: 'BAD_CERTIFICATE',
        );
      case DioExceptionType.unknown:
        return UnexpectedException(
          message: error.message ?? 'An unexpected network error occurred.',
          code: 'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'] as String;
      }
      if (data.containsKey('error') && data['error'] is String) {
        return data['error'] as String;
      }
    }
    return null;
  }
}

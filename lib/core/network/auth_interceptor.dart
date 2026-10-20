import 'package:dio/dio.dart';
import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/security/token_manager.dart';
import 'package:neram_pos/core/services/logger_service.dart';

/// Interceptor that handles Bearer token injection and handles 401 unauthorized errors.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.tokenManager, required this.dio});

  final TokenManager tokenManager;
  final Dio dio;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublicPath =
        options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.refreshToken);

    if (!isPublicPath) {
      final token = await tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiEndpoints.refreshToken) &&
        !err.requestOptions.path.contains(ApiEndpoints.login)) {
      LoggerService.warning(
        'Received 401 Unauthorized for ${err.requestOptions.path}. Attempting token refresh.',
      );

      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty && !_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshResponse = await dio.post<Map<String, dynamic>>(
            ApiEndpoints.refreshToken,
            data: {'refresh_token': refreshToken},
          );

          final newAccessToken =
              refreshResponse.data?['access_token'] as String?;
          final newRefreshToken =
              (refreshResponse.data?['refresh_token'] as String?) ??
              refreshToken;

          if (newAccessToken != null) {
            await tokenManager.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            _isRefreshing = false;

            // Retry the original failed request with the new access token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await dio.fetch<dynamic>(requestOptions);
            return handler.resolve(response);
          }
        } catch (refreshErr) {
          LoggerService.error('Token refresh failed: $refreshErr');
          await tokenManager.clearTokens();
        } finally {
          _isRefreshing = false;
        }
      } else {
        await tokenManager.clearTokens();
      }
    }

    return handler.next(err);
  }
}

import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/security/token_manager.dart';
import 'package:neram_pos/data/models/auth_token_model.dart';
import 'package:neram_pos/data/models/user_model.dart';
import 'package:neram_pos/data/repositories/base_repository.dart';

/// Abstract contract for authentication operations (clean architecture contract).
abstract class AuthRepository {
  Future<UserModel> login({required String username, required String password});
  Future<void> logout();
  Future<UserModel?> getProfile();
  Future<bool> isAuthenticated();
}

/// Concrete implementation of [AuthRepository] utilizing [ApiClient] and [TokenManager].
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  AuthRepositoryImpl({required this.apiClient, required this.tokenManager});

  final ApiClient apiClient;
  final TokenManager tokenManager;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    return safeCall(() async {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      final data = response.data ?? <String, dynamic>{};
      final tokenData =
          data['token'] as Map<String, dynamic>? ??
          data['tokens'] as Map<String, dynamic>? ??
          data;

      final tokenModel = AuthTokenModel.fromJson(tokenData);
      await tokenManager.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );

      final userData = data['user'] as Map<String, dynamic>? ?? data;
      return UserModel.fromJson(userData);
    });
  }

  @override
  Future<void> logout() async {
    return safeCall(() async {
      try {
        await apiClient.post<dynamic>(ApiEndpoints.logout);
      } catch (_) {
        // Ignore remote logout network errors to ensure local tokens are always cleared
      } finally {
        await tokenManager.clearTokens();
      }
    });
  }

  @override
  Future<UserModel?> getProfile() async {
    return safeCall(() async {
      final isAuth = await isAuthenticated();
      if (!isAuth) return null;

      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.staffProfile,
      );
      final data = response.data ?? <String, dynamic>{};
      final userData = data['user'] as Map<String, dynamic>? ?? data;
      return UserModel.fromJson(userData);
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    return tokenManager.hasValidToken();
  }
}

import 'package:neram_pos/core/security/secure_storage_service.dart';

/// Centralized token manager responsible for saving, fetching, and clearing tokens.
class TokenManager {
  TokenManager({required SecureStorageService storageService})
    : _storage = storageService;

  final SecureStorageService _storage;

  static const String _accessTokenKey = 'neram_access_token';
  static const String _refreshTokenKey = 'neram_refresh_token';
  static const String _tokenExpiryKey = 'neram_token_expiry';

  String? _cachedAccessToken;

  /// Fast in-memory token retrieval or loads from secure storage if cache is empty.
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
      return _cachedAccessToken;
    }
    _cachedAccessToken = await _storage.read(_accessTokenKey);
    return _cachedAccessToken;
  }

  /// Retrieves the stored refresh token.
  Future<String?> getRefreshToken() async {
    return _storage.read(_refreshTokenKey);
  }

  /// Saves newly issued tokens safely to secure hardware storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    _cachedAccessToken = accessToken;
    await Future.wait([
      _storage.write(_accessTokenKey, accessToken),
      _storage.write(_refreshTokenKey, refreshToken),
      if (expiresAt != null)
        _storage.write(_tokenExpiryKey, expiresAt.toIso8601String()),
    ]);
  }

  /// Clears stored tokens and in-memory cache upon staff logout or invalidated session.
  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    await Future.wait([
      _storage.delete(_accessTokenKey),
      _storage.delete(_refreshTokenKey),
      _storage.delete(_tokenExpiryKey),
    ]);
  }

  /// Determines whether an active access token exists.
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

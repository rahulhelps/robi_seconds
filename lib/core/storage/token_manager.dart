import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  TokenManager._();

  static final TokenManager _instance = TokenManager._();
  static TokenManager get instance => _instance;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // bdapps (apiv2) session tokens. Kept apart from the main-backend token above
  // so the two servers never overwrite each other's token.
  static const String _authAccessKey = 'auth_access_token';
  static const String _authRefreshKey = 'auth_refresh_token';
  static String? _cachedAccessToken;

  static Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> setAccessToken(String token) async {
    _cachedAccessToken = token;
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    _cachedAccessToken = accessToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> saveAccessToken(String token) async {
    await setAccessToken(token);
  }

  static Future<void> saveRefreshToken(String token) async {
    await setRefreshToken(token);
  }

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    await saveTokens(accessToken, refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _authAccessKey);
    await _storage.delete(key: _authRefreshKey);
    _cachedAccessToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<void> clearAll() async {
    await clearTokens();
  }

  static Future<String?> getToken() async {
    return await getAccessToken();
  }

  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && accessToken.isNotEmpty && refreshToken != null && refreshToken.isNotEmpty;
  }

  static String? get cachedAccessToken => _cachedAccessToken;

  // ── bdapps (apiv2) session ───────────────────────────────────────────────

  static Future<String?> getAuthAccessToken() =>
      _storage.read(key: _authAccessKey);

  static Future<String?> getAuthRefreshToken() =>
      _storage.read(key: _authRefreshKey);

  static Future<void> saveAuthTokens(
      String accessToken, String refreshToken) async {
    await _storage.write(key: _authAccessKey, value: accessToken);
    await _storage.write(key: _authRefreshKey, value: refreshToken);
  }

  static Future<void> saveAuthAccessToken(String token) =>
      _storage.write(key: _authAccessKey, value: token);

  static Future<void> saveAuthRefreshToken(String token) =>
      _storage.write(key: _authRefreshKey, value: token);
}

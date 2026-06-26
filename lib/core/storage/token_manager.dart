import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages JWT access and refresh tokens in secure storage.
class TokenManager {
  static const _storage = FlutterSecureStorage();

  /// In-memory mirror of the access token. Lets sync widget builds (e.g. the
  /// avatar [CachedNetworkImage], which streams from an authenticated endpoint)
  /// attach a Bearer header without an async storage read. Refreshed on every
  /// save/read and cleared on logout.
  static String? _cachedAccessToken;
  static String? get cachedAccessToken => _cachedAccessToken;

  // ── Save ─────────────────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    print("Saved accessToken: $accessToken");
  }

  static Future<void> saveAccessToken(String token) async {
    _cachedAccessToken = token;
    await _storage.write(key: 'accessToken', value: token);
    print("Saved accessToken: $token");
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refreshToken', value: token);
    print("Saved refreshToken: $token");
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'accessToken');
    _cachedAccessToken = token;
    print("Loaded token: $token");
    return token;
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    _cachedAccessToken = token;
    print("Loaded token: $token");
    return token;
  }

  static Future<String?> getRefreshToken() async =>
      _storage.read(key: 'refreshToken');

  // ── Clear ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    _cachedAccessToken = null;
    await _storage.deleteAll();
  }
}

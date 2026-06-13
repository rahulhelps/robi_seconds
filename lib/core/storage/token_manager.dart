import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages JWT access and refresh tokens in secure storage.
class TokenManager {
  static const _storage = FlutterSecureStorage();

  // ── Save ─────────────────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    print("Saved accessToken: $accessToken");
  }

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
    print("Saved accessToken: $token");
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refreshToken', value: token);
    print("Saved refreshToken: $token");
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'accessToken');
    print("Loaded token: $token");
    return token;
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    print("Loaded token: $token");
    return token;
  }

  static Future<String?> getRefreshToken() async =>
      _storage.read(key: 'refreshToken');

  // ── Clear ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async => _storage.deleteAll();
}

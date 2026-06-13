import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists user profile data and subscription status in secure storage.
class UserStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyUser = 'user';
  static const _keyIsSubscriptionActive = 'isSubscriptionActive';
  static const _keyPhone = 'userPhone';

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Saves the full user map as a JSON string.
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user));

    // Also cache subscription status for quick access
    final isActive = user['isSubscriptionActive'];
    if (isActive != null) {
      await _storage.write(
        key: _keyIsSubscriptionActive,
        value: isActive.toString(),
      );
    }
  }

  /// Saves the phone number for use on next app launch (subscription check).
  static Future<void> savePhone(String phone) async {
    await _storage.write(key: _keyPhone, value: phone);
  }

  /// Updates only the isSubscriptionActive flag without overwriting the full user.
  static Future<void> updateSubscriptionStatus(bool isActive) async {
    await _storage.write(
      key: _keyIsSubscriptionActive,
      value: isActive.toString(),
    );
    // Also keep the nested user map in sync.
    final raw = await _storage.read(key: _keyUser);
    if (raw != null) {
      final user = jsonDecode(raw) as Map<String, dynamic>;
      user['isSubscriptionActive'] = isActive;
      await _storage.write(key: _keyUser, value: jsonEncode(user));
    }
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  /// Returns the stored user as a Map, or null if not found.
  static Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Returns true if the user has an active subscription.
  static Future<bool> getSubscriptionStatus() async {
    final status = await _storage.read(key: _keyIsSubscriptionActive);
    return status == 'true';
  }

  /// Returns the stored phone number, or null if not set.
  static Future<String?> getPhone() async {
    return _storage.read(key: _keyPhone);
  }

  // ── Clear ────────────────────────────────────────────────────────────────

  static Future<void> clearUser() async {
    await _storage.delete(key: _keyUser);
    await _storage.delete(key: _keyIsSubscriptionActive);
    await _storage.delete(key: _keyPhone);
  }
}

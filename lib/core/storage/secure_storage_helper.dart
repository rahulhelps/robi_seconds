import 'token_manager.dart';
import 'user_storage.dart';

/// SecureStorageHelper is kept for backward compatibility.
/// New code should use [TokenManager] and [UserStorage] directly.
class SecureStorageHelper {
  SecureStorageHelper._();

  // ── Token delegates ───────────────────────────────────────────────────────

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) =>
      TokenManager.saveTokens(
        accessToken,
        refreshToken,
      );

  static Future<String?> getAccessToken() => TokenManager.getAccessToken();
  static Future<String?> getRefreshToken() => TokenManager.getRefreshToken();

  // ── Subscription delegates ────────────────────────────────────────────────

  static Future<void> saveSubscriptionStatus(bool isActive) =>
      UserStorage.clearUser(); // use UserStorage.saveUser() instead

  static Future<bool> getSubscriptionStatus() =>
      UserStorage.getSubscriptionStatus();

  // ── Clear ─────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await TokenManager.clearAll();
    await UserStorage.clearUser();
  }
}

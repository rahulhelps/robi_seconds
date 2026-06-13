import '../data/auth_datasource.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/storage/user_storage.dart';

class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository(this._dataSource);

  /// Calls the phone-auth endpoint and persists all response data.
  Future<void> phoneAuth(String phoneNumber) async {
    // AuthService (inside AuthDataSource) already saves tokens + user.
    // We call it here to keep the BLoC → Repository → DataSource chain intact.
    await _dataSource.phoneAuth(phoneNumber);
  }

  /// Returns the locally cached user, or null if not logged in.
  Future<Map<String, dynamic>?> getMe() async {
    return _dataSource.getMe();
  }

  /// Returns whether the user has an active subscription.
  Future<bool> getSubscriptionStatus() async {
    return UserStorage.getSubscriptionStatus();
  }

  /// Checks if a valid access token exists (used for persistent session).
  Future<bool> isLoggedIn() async {
    final token = await TokenManager.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears all stored tokens and user data.
  Future<void> logout() async {
    await TokenManager.clearAll();
    await UserStorage.clearUser();
  }
}

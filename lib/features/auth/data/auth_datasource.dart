import '../../../../core/services/auth_service.dart';

/// AuthDataSource delegates all network calls to [AuthService].
/// The old Dio-based implementation has been replaced with http.
class AuthDataSource {
  Future<Map<String, dynamic>> phoneAuth(String phoneNumber) async {
    return AuthService.loginWithPhone(phoneNumber);
  }

  Future<Map<String, dynamic>?> getMe() async {
    return AuthService.getCurrentUser();
  }
}

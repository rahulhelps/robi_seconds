import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../storage/token_manager.dart';
import '../storage/user_storage.dart';
import 'auth_service.dart';

const _baseUrl = ApiConstants.baseUrl;

// ── Result models ─────────────────────────────────────────────────────────────

enum BDAppsSubscriptionStatus {
  registered,
  unregistered,
  initialChargingPending,
  unknown,
}

class BDAppsOtpResult {
  final bool success;
  final String referenceNo;

  /// Human-readable message from the server shown in snackbar on failure.
  final String? statusDetail;

  const BDAppsOtpResult({
    required this.success,
    this.referenceNo = '',
    this.statusDetail,
  });
}

class BDAppsVerifyResult {
  final bool success;
  final String? errorMessage;

  const BDAppsVerifyResult({required this.success, this.errorMessage});
}

class BDAppsSubscriptionResult {
  final BDAppsSubscriptionStatus status;
  final bool isSubscribed;

  const BDAppsSubscriptionResult({
    required this.status,
    required this.isSubscribed,
  });
}

class BDAppsUnsubscribeResult {
  final bool success;
  final String? errorMessage;

  const BDAppsUnsubscribeResult({required this.success, this.errorMessage});
}

// ── Service ───────────────────────────────────────────────────────────────────

class BDAppsService {
  /// Sentinel returned by [sendOtp] when the number is already registered and
  /// the platform signed the user in without an OTP. AuthBloc keys off this.
  static const alreadyRegisteredDetail = 'user already registered';

  /// Strips a leading +88 / 88 country code if the caller included one.
  static String _clean(String phone) {
    if (phone.startsWith('+88')) return phone.substring(3);
    if (phone.startsWith('88') && phone.length > 11) return phone.substring(2);
    return phone;
  }

  // ── Send OTP ────────────────────────────────────────────────────────────────

  static Future<BDAppsOtpResult> sendOtp(String phone) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/otp/send');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phoneNumber': _clean(phone)}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[OTP] sendOtp ← ${response.statusCode} ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      final data = body['data'] as Map<String, dynamic>?;

      if (success && data != null) {
        if (data['alreadyRegistered'] == true) {
          return const BDAppsOtpResult(
            success: false,
            statusDetail: alreadyRegisteredDetail,
          );
        }
        final referenceNo = data['referenceNo']?.toString() ?? '';
        if (referenceNo.isNotEmpty) {
          return BDAppsOtpResult(success: true, referenceNo: referenceNo);
        }
      }

      return BDAppsOtpResult(
        success: false,
        statusDetail: body['message']?.toString() ?? 'Failed to send OTP.',
      );
    } on TimeoutException {
      return const BDAppsOtpResult(
        success: false,
        statusDetail: 'Request timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('[OTP] sendOtp ✗ $e');
      return const BDAppsOtpResult(
        success: false,
        statusDetail: 'Network error. Please check your connection.',
      );
    }
  }

  // ── Verify OTP ──────────────────────────────────────────────────────────────

  /// POST /auth/otp/verify { phoneNumber, referenceNo, code }.
  ///
  /// On success the platform returns the JWT pair + user, which we persist here
  /// so the caller is fully authenticated without a second request.
  static Future<BDAppsVerifyResult> verifyOtp(
    String otp,
    String referenceNo,
    String phone,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/otp/verify');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phoneNumber': _clean(phone),
              'referenceNo': referenceNo,
              'code': otp,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[OTP] verifyOtp ← ${response.statusCode} ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (body['success'] == true && data != null) {
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          await TokenManager.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        final user = data['user'] as Map<String, dynamic>?;
        if (user != null) await UserStorage.saveUser(user);
        return const BDAppsVerifyResult(success: true);
      }

      return BDAppsVerifyResult(
        success: false,
        errorMessage:
            body['message']?.toString() ?? 'Invalid OTP. Please try again.',
      );
    } on TimeoutException {
      return const BDAppsVerifyResult(
        success: false,
        errorMessage: 'Request timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('[OTP] verifyOtp ✗ $e');
      return const BDAppsVerifyResult(
        success: false,
        errorMessage: 'Network error. Please check your connection.',
      );
    }
  }

  // ── Check Subscription ───────────────────────────────────────────────────────

  /// GET /auth/me → maps `isSubscriptionActive` to a subscription status.
  /// Requires a valid session (the splash screen only calls this when a token
  /// exists). [phone] is unused now but kept for call-site compatibility.
  static Future<BDAppsSubscriptionResult> checkSubscription(String phone) async {
    final res = await AuthService.authenticatedGet('/auth/me');
    final data = res['data'] as Map<String, dynamic>?;
    final active = data?['isSubscriptionActive'] == true;

    debugPrint('[OTP] checkSubscription ← isSubscriptionActive=$active');

    return BDAppsSubscriptionResult(
      status: active
          ? BDAppsSubscriptionStatus.registered
          : BDAppsSubscriptionStatus.unregistered,
      isSubscribed: active,
    );
  }

  // ── Unsubscribe ──────────────────────────────────────────────────────────────

  /// POST /auth/unsubscribe (authenticated).
  static Future<BDAppsUnsubscribeResult> unsubscribe(String phone) async {
    try {
      final res = await AuthService.authenticatedPost('/auth/unsubscribe', {});
      debugPrint('[OTP] unsubscribe ← $res');

      if (res['success'] == true) {
        return const BDAppsUnsubscribeResult(success: true);
      }
      return BDAppsUnsubscribeResult(
        success: false,
        errorMessage: res['message']?.toString() ?? 'Failed to unsubscribe.',
      );
    } on TimeoutException {
      return const BDAppsUnsubscribeResult(
        success: false,
        errorMessage: 'Request timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('[OTP] unsubscribe ✗ $e');
      return BDAppsUnsubscribeResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}

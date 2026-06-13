import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// Base URL for BDApps PHP APIs.
const _bdappsBaseUrl = 'http://147.93.29.196:8080';

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
  /// Reads statusDetail first, falls back to message field.
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
  // ── Send OTP ────────────────────────────────────────────────────────────────

  /// POST /send_otp.php — multipart/form-data { user_mobile }
  ///
  /// Navigate to OTP screen ONLY when:
  ///   success == true  AND  referenceNo is non-empty
  ///
  /// Anything else → stay on Auth Screen, show statusDetail in snackbar.
  static Future<BDAppsOtpResult> sendOtp(String phone) async {
    // Strip +88 / 88 prefix if accidentally included.
    final cleanPhone = phone.startsWith('+88')
        ? phone.substring(3)
        : (phone.startsWith('88') && phone.length > 11)
            ? phone.substring(2)
            : phone;

    try {
      final uri = Uri.parse('$_bdappsBaseUrl/send_otp.php');

      // MultipartRequest sends genuine multipart/form-data (not url-encoded).
      final request = http.MultipartRequest('POST', uri)
        ..fields['user_mobile'] = cleanPhone;

      debugPrint('╔══════════════════════════════════════════════');
      debugPrint('║ [BDApps] sendOtp REQUEST');
      debugPrint('║  URL   : $uri');
      debugPrint('║  Field : user_mobile=$cleanPhone');
      debugPrint('╚══════════════════════════════════════════════');

      final streamed =
          await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      debugPrint('╔══════════════════════════════════════════════');
      debugPrint('║ [BDApps] sendOtp RESPONSE');
      debugPrint('║  HTTP : ${response.statusCode}');
      debugPrint('║  Body : ${response.body}');
      debugPrint('╚══════════════════════════════════════════════');

      final body        = jsonDecode(response.body) as Map<String, dynamic>;
      final successFlag = body['success'] == true;
      final referenceNo = body['referenceNo']?.toString() ?? '';
      // statusDetail takes priority over message for the snackbar text.
      final detail =
          (body['statusDetail'] ?? body['message'])?.toString() ?? '';

      debugPrint('[BDApps] sendOtp parsed → success=$successFlag '
          'referenceNo="$referenceNo" detail="$detail"');

      // ── THE ONLY SUCCESS CONDITION ─────────────────────────────────────────
      if (successFlag && referenceNo.isNotEmpty) {
        debugPrint('[BDApps] sendOtp ✓ → navigate to OTP screen');
        return BDAppsOtpResult(success: true, referenceNo: referenceNo);
      }

      // ── Failure: stay on Auth Screen ───────────────────────────────────────
      debugPrint('[BDApps] sendOtp ✗ → stay on Auth Screen');
      return BDAppsOtpResult(
        success: false,
        statusDetail: detail.isNotEmpty ? detail : 'Failed to send OTP.',
      );
    } on TimeoutException {
      debugPrint('[BDApps] sendOtp ✗ Timeout');
      return const BDAppsOtpResult(
        success: false,
        statusDetail: 'Request timed out. Please try again.',
      );
    } catch (e, st) {
      debugPrint('[BDApps] sendOtp ✗ $e\n$st');
      return const BDAppsOtpResult(
        success: false,
        statusDetail: 'Network error. Please check your connection.',
      );
    }
  }

  // ── Verify OTP ──────────────────────────────────────────────────────────────

  /// POST /verify_otp.php — multipart/form-data { Otp (capital O), referenceNo }
  static Future<BDAppsVerifyResult> verifyOtp(
    String otp,
    String referenceNo,
  ) async {
    try {
      final uri = Uri.parse('$_bdappsBaseUrl/verify_otp.php');
      debugPrint('[BDApps] verifyOtp → Otp=$otp referenceNo=$referenceNo');

      final request = http.MultipartRequest('POST', uri)
        ..fields['Otp'] = otp
        ..fields['referenceNo'] = referenceNo;

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      debugPrint(
          '[BDApps] verifyOtp ← ${response.statusCode} ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['statusCode']?.toString() == 'S1000') {
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
      debugPrint('[BDApps] verifyOtp ✗ $e');
      return const BDAppsVerifyResult(
        success: false,
        errorMessage: 'Network error. Please check your connection.',
      );
    }
  }

  // ── Check Subscription ───────────────────────────────────────────────────────

  /// POST /check_subscription.php — multipart/form-data { user_mobile }
  static Future<BDAppsSubscriptionResult> checkSubscription(
    String phone,
  ) async {
    final uri = Uri.parse('$_bdappsBaseUrl/check_subscription.php');
    debugPrint('[BDApps] checkSubscription → user_mobile=$phone');

    final request = http.MultipartRequest('POST', uri)
      ..fields['user_mobile'] = phone;

    final streamed = await request.send().timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamed);

    debugPrint(
        '[BDApps] checkSubscription ← ${response.statusCode} ${response.body}');

    final body         = jsonDecode(response.body) as Map<String, dynamic>;
    final statusStr    = body['subscriptionStatus']?.toString() ?? '';
    final isSubscribed = body['isSubscribed'] == true;

    final BDAppsSubscriptionStatus status;
    switch (statusStr) {
      case 'REGISTERED':
        status = BDAppsSubscriptionStatus.registered;
      case 'UNREGISTERED':
        status = BDAppsSubscriptionStatus.unregistered;
      case 'INITIAL CHARGING PENDING':
        status = BDAppsSubscriptionStatus.initialChargingPending;
      default:
        status = BDAppsSubscriptionStatus.unknown;
    }

    return BDAppsSubscriptionResult(status: status, isSubscribed: isSubscribed);
  }

  // ── Unsubscribe ──────────────────────────────────────────────────────────────

  /// POST /unsubscribe.php — multipart/form-data { user_mobile }
  static Future<BDAppsUnsubscribeResult> unsubscribe(String phone) async {
    // Strip +88 / 88 prefix if accidentally included.
    final cleanPhone = phone.startsWith('+88')
        ? phone.substring(3)
        : (phone.startsWith('88') && phone.length > 11)
            ? phone.substring(2)
            : phone;

    try {
      final uri = Uri.parse('$_bdappsBaseUrl/unsubscribe.php');
      final request = http.MultipartRequest('POST', uri)
        ..fields['user_mobile'] = cleanPhone;

      debugPrint('[BDApps] unsubscribe → user_mobile=$cleanPhone');

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      debugPrint('[BDApps] unsubscribe ← ${response.statusCode} ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (body['success'] == true || body['statusCode']?.toString() == 'S1000') {
        return const BDAppsUnsubscribeResult(success: true);
      }
      return BDAppsUnsubscribeResult(
        success: false, 
        errorMessage: body['error']?.toString() ?? 'Failed to unsubscribe.',
      );
    } on TimeoutException {
      return const BDAppsUnsubscribeResult(
        success: false, 
        errorMessage: 'Request timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('[BDApps] unsubscribe ✗ $e');
      return const BDAppsUnsubscribeResult(
        success: false, 
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}

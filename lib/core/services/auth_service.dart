import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import '../constants.dart';
import '../storage/token_manager.dart';
import '../storage/user_storage.dart';

/// Base URL for all API calls — single source of truth in [ApiConstants].
const _baseUrl = ApiConstants.baseUrl;

/// AuthService handles all authentication-related HTTP calls using the `http`
/// package. It also manages automatic token refresh on 401 responses.
class AuthService {
  // ── Login ─────────────────────────────────────────────────────────────────

  /// Calls POST /auth/phone-auth with the provided [phoneNumber].
  ///
  /// On success, saves:
  ///  - accessToken + refreshToken via [TokenManager]
  ///  - full user object + isSubscriptionActive via [UserStorage]
  ///
  /// Throws a [String] error message on failure.
  static Future<Map<String, dynamic>> loginWithPhone(String phoneNumber) async {
    final uri = Uri.parse('$_baseUrl/auth/phone-auth');

    // ── Debug: log request ──────────────────────────────────────────────────
    print('[AuthService] POST $uri');
    print('[AuthService] Body: ${jsonEncode({'phoneNumber': phoneNumber})}');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phoneNumber': phoneNumber}),
        )
        .timeout(const Duration(seconds: 15));

    // ── Debug: log raw response ─────────────────────────────────────────────
    print('[AuthService] Status: ${response.statusCode}');
    print('[AuthService] Body: ${response.body}');

    // _parseResponse returns the full root JSON map
    final rootJson = _parseResponse(response);
    print('[AuthService] Parsed root JSON: $rootJson');

    // The server wraps payload inside a 'data' key:
    // { "success": true, "data": { "accessToken": ..., "refreshToken": ..., "user": ... } }
    final bool success = rootJson['success'] == true;
    if (!success) {
      final msg = rootJson['message'] ?? 'Login failed.';
      throw msg.toString();
    }

    final payload = rootJson['data'] as Map<String, dynamic>?;
    print('[AuthService] Payload (data): $payload');

    if (payload == null) {
      throw 'Invalid server response: "data" key is missing.';
    }

    // Extract tokens from inside 'data'
    final accessToken = payload['accessToken'] as String?;
    final refreshToken = payload['refreshToken'] as String?;

    print('[AuthService] Token after login: $accessToken');
    print('[AuthService] refreshToken: $refreshToken');

    if (accessToken == null || refreshToken == null) {
      throw 'Invalid server response: tokens missing inside "data".';
    }

    await TokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Persist user object (also inside 'data')
    final user = payload['user'] as Map<String, dynamic>?;
    if (user != null) {
      await UserStorage.saveUser(user);
      print('[AuthService] User saved: $user');
    }

    return payload;
  }

  // ── Token Refresh (single-flight) ──────────────────────────────────────────

  static Future<bool>? _refreshFuture;

  static Future<bool> refreshToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  static Future<bool> _performRefresh() async {
    final storedRefreshToken = await TokenManager.getRefreshToken();
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      await logout();
      return false;
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/refresh');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': storedRefreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final root = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = (root['data'] as Map<String, dynamic>?) ?? root;
        final newToken = payload['accessToken'] as String?;
        final newRefreshToken = payload['refreshToken'] as String?;

        if (newToken != null && newToken.isNotEmpty) {
          await TokenManager.saveAccessToken(newToken);
          // Persist the rotated refresh token so the next refresh uses it.
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await TokenManager.saveRefreshToken(newRefreshToken);
          }
          print('[AuthService] Silent refresh succeeded.');
          return true;
        }
      }

      // 401/403 means the refresh token itself is invalid/expired/revoked —
      // the session is genuinely over, so clear it.
      if (response.statusCode == 401 || response.statusCode == 403) {
        print('[AuthService] Refresh rejected (${response.statusCode}). Logging out.');
        await logout();
      }
      // Any other status (5xx, unexpected body) is treated as transient: keep
      // the session so the user can retry rather than being kicked out.
      return false;
    } catch (e) {
      print('[AuthService] Refresh failed transiently: $e');
      return false;
    }
  }

  /// Awaits a refresh and throws a user-facing message on failure, telling a
  /// genuinely-expired session apart from a transient network error — so a
  /// connectivity blip during refresh doesn't surface as "logged out".
  static Future<void> _ensureFreshTokenOrThrow() async {
    final refreshed = await refreshToken();
    if (refreshed) return;
    final stillHasSession =
        (await TokenManager.getRefreshToken())?.isNotEmpty ?? false;
    if (stillHasSession) {
      throw 'Could not reach the server. Please check your connection and try again.';
    }
    throw 'Session expired. Please log in again.';
  }

  // ── Authenticated GET helper ──────────────────────────────────────────────

  /// Makes an authenticated GET request to [path].
  /// Automatically retries once after refreshing the token on a 401.
  static Future<Map<String, dynamic>> authenticatedGet(String path) async {
    final result = await _doGet(path);
    if (result['__status'] == 401) {
      await _ensureFreshTokenOrThrow();
      return _doGet(path);
    }
    return result;
  }

  /// Makes an authenticated POST request to [path] with [body].
  /// Automatically retries once after refreshing the token on a 401.
  static Future<Map<String, dynamic>> authenticatedPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    final result = await _doPost(path, body);
    if (result['__status'] == 401) {
      await _ensureFreshTokenOrThrow();
      return _doPost(path, body);
    }
    return result;
  }

  /// Makes an authenticated PUT request to [path] with [body].
  /// Automatically retries once after refreshing the token on a 401.
  static Future<Map<String, dynamic>> authenticatedPut(
    String path,
    Map<String, dynamic> body,
  ) async {
    final result = await _doPut(path, body);
    if (result['__status'] == 401) {
      await _ensureFreshTokenOrThrow();
      return _doPut(path, body);
    }
    return result;
  }

  /// Makes an authenticated DELETE request to [path].
  /// Automatically retries once after refreshing the token on a 401.
  static Future<Map<String, dynamic>> authenticatedDelete(String path) async {
    final result = await _doDelete(path);
    if (result['__status'] == 401) {
      await _ensureFreshTokenOrThrow();
      return _doDelete(path);
    }
    return result;
  }

  /// Makes an authenticated GET request to [path] and returns the raw response.
  /// Useful for binary downloads. Automatically retries once on 401.
  static Future<http.Response> authenticatedGetRaw(String url) async {
    final token = await TokenManager.getAccessToken();
    var response = await http.get(
      Uri.parse(url),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      await _ensureFreshTokenOrThrow();
      
      final newToken = await TokenManager.getAccessToken();
      response = await http.get(
        Uri.parse(url),
        headers: {
          if (newToken != null) 'Authorization': 'Bearer $newToken',
        },
      ).timeout(const Duration(seconds: 30));
    }
    return response;
  }

  // ── Get Current User ──────────────────────────────────────────────────────

  /// Returns the locally-stored user map (no network call needed).
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return UserStorage.getUser();
  }

  /// Returns the current access token string, or null if not logged in.
  static Future<String?> getAccessToken() async {
    return TokenManager.getAccessToken();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _doGet(String path) async {
    final token = await TokenManager.getAccessToken();
    print('[AuthService] GET token: $token');
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) return {'__status': 401};
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> _doPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await TokenManager.getAccessToken();
    print('[AuthService] POST token: $token');
    final uri = Uri.parse('$_baseUrl$path');

    // ── Debug: log outgoing request body ─────────────────────────────────────
    print('[AuthService] POST $uri');
    print('[AuthService] REQUEST BODY:\n${jsonEncode(body)}');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    // ── Debug: log raw response ───────────────────────────────────────────────
    print('[AuthService] RESPONSE STATUS: ${response.statusCode}');
    print('[AuthService] RESPONSE BODY:\n${response.body}');

    if (response.statusCode == 401) return {'__status': 401};
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> _doPut(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await TokenManager.getAccessToken();
    print('[AuthService] PUT token: $token');
    final uri = Uri.parse('$_baseUrl$path');

    print('[AuthService] PUT $uri');
    print('[AuthService] REQUEST BODY:\n${jsonEncode(body)}');

    final response = await http
        .put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    print('[AuthService] RESPONSE STATUS: ${response.statusCode}');
    print('[AuthService] RESPONSE BODY:\n${response.body}');

    if (response.statusCode == 401) return {'__status': 401};
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> _doDelete(String path) async {
    final token = await TokenManager.getAccessToken();
    print('[AuthService] DELETE token: $token');
    final uri = Uri.parse('$_baseUrl$path');

    print('[AuthService] DELETE $uri');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    print('[AuthService] RESPONSE STATUS: ${response.statusCode}');
    print('[AuthService] RESPONSE BODY:\n${response.body}');

    if (response.statusCode == 401) return {'__status': 401};
    return _parseResponse(response);
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Uploads an avatar image to /upload/avatar using multipart/form-data.
  static Future<Map<String, dynamic>> uploadAvatar(String filePath, String fileName, String mimeType) async {
    final token = await TokenManager.getAccessToken();
    if (token == null) throw 'Not authenticated';

    final uri = Uri.parse('$_baseUrl/upload/avatar');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    final imageFile = File(filePath);
    
    request.files.add(
      http.MultipartFile(
        'avatar',
        imageFile.openRead(),
        imageFile.lengthSync(),
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    print('[AuthService] POST Multipart $uri');

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    print('[AuthService] RESPONSE STATUS: ${response.statusCode}');
    print('[AuthService] RESPONSE BODY:\n${response.body}');

    if (response.statusCode == 401) {
      await _ensureFreshTokenOrThrow();
      // Retry once
      return uploadAvatar(filePath, fileName, mimeType);
    }
    
    return _parseResponse(response);
  }

  /// Parses the response body and throws a readable [String] on error.
  /// Handles both simple `message` strings and Express/Mongoose `errors` arrays.
  static Map<String, dynamic> _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode == 200 || statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return {'success': true, 'data': decoded};
      }
      return decoded as Map<String, dynamic>;
    }

    // Try to extract a developer-friendly server error message
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      // Express-validator / Mongoose often sends an errors array
      final errorsRaw = body['errors'];
      if (errorsRaw is List && errorsRaw.isNotEmpty) {
        final messages = errorsRaw
            .map((e) => e is Map ? (e['msg'] ?? e['message'] ?? '') : e.toString())
            .where((s) => s.toString().isNotEmpty)
            .join(' | ');
        if (messages.isNotEmpty) throw messages;
      }

      // Fallback: top-level message / error key
      final msg = body['message'] ?? body['error'] ?? 'Request failed ($statusCode).';
      throw msg.toString();
    } catch (e) {
      if (e is String) rethrow;
      throw 'Request failed ($statusCode).';
    }
  }

  /// Clears all stored tokens and user data (effectively logs the user out).
  static Future<void> logout() async {
    await TokenManager.clearAll();
    await UserStorage.clearUser();
  }
}



import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../storage/token_manager.dart';

class EntitlementService {
  EntitlementService._();

  static const _ttl = Duration(hours: 1);
  static DateTime? _lastFetchedAt;
  static Map<String, dynamic>? _cachedEntitlement;

  static Future<Map<String, dynamic>> fetchEntitlement({bool forceRefresh = false}) async {
    final now = DateTime.now();

    if (!forceRefresh &&
        _cachedEntitlement != null &&
        _lastFetchedAt != null &&
        now.difference(_lastFetchedAt!) < _ttl) {
      debugPrint('[EntitlementService] Returning cached entitlement');
      return _cachedEntitlement!;
    }

    try {
      final token = await TokenManager.getAccessToken();
      if (token == null || token.isEmpty) {
        return _notPremium();
      }

      final response = await ApiClient.dio.get(
        '/v1/entitlement',
        options: Options(headers: {'Authorization': 'Bearer token'}),
      );

      final data = Map<String, dynamic>.from(response.data['data'] ?? response.data);
      _cachedEntitlement = data;
      _lastFetchedAt = now;
      debugPrint('[EntitlementService] Fetched entitlement: $data');
      return data;
    } on DioException catch (e) {
      debugPrint('[EntitlementService] Network error: ${e.message}');
      if (_cachedEntitlement != null) {
        debugPrint('[EntitlementService] Returning stale cached entitlement due to network error');
        return _cachedEntitlement!;
      }
      return _notPremium();
    } catch (e) {
      debugPrint('[EntitlementService] Unexpected error: $e');
      if (_cachedEntitlement != null) {
        return _cachedEntitlement!;
      }
      return _notPremium();
    }
  }

  static Future<bool> isPremium({bool forceRefresh = false}) async {
    final entitlement = await fetchEntitlement(forceRefresh: forceRefresh);
    return entitlement['is_premium'] == true;
  }

  static Future<void> invalidateCache() async {
    _cachedEntitlement = null;
    _lastFetchedAt = null;
    debugPrint('[EntitlementService] Cache invalidated');
  }

  static Map<String, dynamic> _notPremium() => {
        'is_premium': false,
        'expires_at': null,
        'features': <String>[],
      };
}
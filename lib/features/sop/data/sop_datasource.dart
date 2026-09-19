import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../domain/sop_model.dart';

/// SopDatasource handles all Statement of Purpose (SOP) API calls.
class SopDatasource {
  /// Sends an SOP request to POST /sop to create/save an SOP.
  /// Returns the saved [SavedSop] object.
  Future<SavedSop> createSop(SopModel model) async {
    final responseMap = await AuthService.authenticatedPost(
      '/sop',
      model.toJson(),
    );

    debugPrint("[SopDatasource] createSop response: $responseMap");

    final data = responseMap['data'] as Map<String, dynamic>? ?? responseMap;
    if (data.containsKey('id') || data.containsKey('_id') || data.containsKey('header')) {
      return SavedSop.fromJson(data);
    }
    
    throw 'Server returned invalid SOP format.';
  }

  /// Calls GET /sop and returns a list of [SavedSop].
  Future<List<SavedSop>> fetchSopHistory() async {
    try {
      final responseMap = await AuthService.authenticatedGet('/sop');

      debugPrint("[SopDatasource] fetchSopHistory response: $responseMap");

      final rawData = responseMap['data'];
      if (rawData is! List) {
        return [];
      }

      return rawData
          .whereType<Map<String, dynamic>>()
          .map(SavedSop.fromJson)
          .toList();
    } catch (e) {
      debugPrint("[SopDatasource] fetchSopHistory error: $e");
      return [];
    }
  }

  /// Calls GET /sop/:id and returns a single [SavedSop].
  Future<SavedSop> getSopDetails(String id) async {
    final responseMap = await AuthService.authenticatedGet('/sop/$id');
    final data = responseMap['data'] as Map<String, dynamic>? ?? responseMap;
    return SavedSop.fromJson(data);
  }

  /// Calls DELETE /sop/:id to delete an SOP.
  Future<void> deleteSop(String id) async {
    await AuthService.authenticatedDelete('/sop/$id');
  }
}

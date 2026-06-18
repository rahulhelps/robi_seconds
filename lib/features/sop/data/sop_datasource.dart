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

    print("[SopDatasource] createSop response: $responseMap");

    final data = responseMap['data'];
    if (data == null) {
      throw 'Server returned no data for SOP.';
    }

    if (data is Map<String, dynamic>) {
      return SavedSop.fromJson(data);
    }
    
    throw 'Invalid SOP response format.';
  }

  /// Calls GET /sop and returns a list of [SavedSop].
  Future<List<SavedSop>> fetchSopHistory() async {
    final responseMap = await AuthService.authenticatedGet('/sop');

    print("[SopDatasource] fetchSopHistory response: $responseMap");

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(SavedSop.fromJson)
        .toList();
  }

  /// Calls GET /sop/:id and returns a single [SavedSop].
  Future<SavedSop> getSopDetails(String id) async {
    final responseMap = await AuthService.authenticatedGet('/sop/$id');
    final data = responseMap['data'];
    if (data == null) throw 'SOP details not found.';
    return SavedSop.fromJson(data as Map<String, dynamic>);
  }

  /// Calls DELETE /sop/:id to delete an SOP.
  Future<void> deleteSop(String id) async {
    await AuthService.authenticatedDelete('/sop/$id');
  }
}

import '../../../../core/services/auth_service.dart';
import '../domain/sop_model.dart';

/// SopDatasource handles all Statement of Purpose (SOP) API calls.
class SopDatasource {
  /// Sends an SOP request to POST /sop.
  /// Returns the generated SOP string.
  Future<String> generateSop(SopModel model) async {
    final responseMap = await AuthService.authenticatedPost(
      '/sop',
      model.toJson(),
    );

    print("[SopDatasource] generateSop response: $responseMap");

    final data = responseMap['data'];
    if (data == null) {
      throw 'Server returned no data for SOP.';
    }

    if (data is String) {
      return data;
    } else if (data is Map<String, dynamic>) {
      final sopText = data['sop'] ?? 
                      data['result'] ?? 
                      data['body'] ?? 
                      data['content'] ?? 
                      data['text'] ?? 
                      '';
      if (sopText.toString().isNotEmpty) {
        return sopText.toString();
      }
    }
    
    throw 'Invalid SOP response format.';
  }

  /// Calls GET /sop and returns a list of [SopModel].
  Future<List<SopModel>> fetchSopHistory() async {
    final responseMap = await AuthService.authenticatedGet('/sop');

    print("[SopDatasource] fetchSopHistory response: $responseMap");

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(SopModel.fromJson)
        .toList();
  }
}

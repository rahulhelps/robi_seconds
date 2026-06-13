import '../../../../core/services/auth_service.dart';
import '../domain/cv_model.dart';
import '../domain/cv_list_item.dart';

const _baseUrl = 'http://147.93.29.196:5000/api/v1';

/// CvDatasource makes authenticated CV-related API calls using [AuthService].
class CvDatasource {
  // ── Generate CV ────────────────────────────────────────────────────────────

  /// Sends the full CV payload to the generate endpoint.
  /// Returns the generated CV id (used for the view API).
  Future<String> generateCv(CvModel cv) async {
    final responseMap =
        await AuthService.authenticatedPost('/cvs/generate', cv.toJson());

    print("API Response: $responseMap");

    final success = responseMap['success'] == true;
    final data = responseMap['data'] as Map<String, dynamic>?;

    if (success && data != null) {
      final String? cvId = data['cvId'] as String?;

      if (cvId == null || cvId.isEmpty) {
        throw "CV ID missing from response";
      }

      print("CV ID: $cvId");
      return cvId;
    } else {
      throw responseMap['message']?.toString() ?? "Something went wrong";
    }
  }

  // ── Fetch CV List ──────────────────────────────────────────────────────────

  /// Calls GET /cvs and returns a list of [CvListItem].
  Future<List<CvListItem>> fetchCvList() async {
    final responseMap = await AuthService.authenticatedGet('/cvs');

    print("API Response: $responseMap");

    // Expected shape: { "success": true, "data": [ {...}, ... ] }
    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(CvListItem.fromJson)
        .toList();
  }

  // ── Get View Token ─────────────────────────────────────────────────────────

  /// Returns the access token for authenticated PDF viewing.
  /// The token is used in the Authorization header of SfPdfViewer.network().
  Future<String?> getAccessToken() async {
    return AuthService.getAccessToken();
  }

  /// Builds the full stream URL for GET /cvs/:id/view.
  String buildViewUrl(String id) => '$_baseUrl/cvs/$id/view';
}

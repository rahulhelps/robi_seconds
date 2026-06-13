import '../../../../core/services/auth_service.dart';
import '../domain/cover_letter_model.dart';

/// CoverLetterDatasource handles all cover-letter API calls.
class CoverLetterDatasource {
  // ── Post Cover Letter ──────────────────────────────────────────────────────

  /// Sends a cover letter to POST /cover-letters.
  /// Returns the saved [SavedCoverLetter] parsed from the response.
  Future<SavedCoverLetter> postCoverLetter(CoverLetterModel model) async {
    final responseMap = await AuthService.authenticatedPost(
      '/cover-letters',
      model.toJson(),
    );

    print("API Response: $responseMap");

    // Expected: { "success": true, "data": { "_id": "...", "header": "...", ... } }
    final data = responseMap['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw 'Server returned no data for cover letter.';
    }
    return SavedCoverLetter.fromJson(data);
  }

  /// Calls GET /cover-letters and returns a list of [SavedCoverLetter].
  Future<List<SavedCoverLetter>> fetchCoverLetters() async {
    final responseMap = await AuthService.authenticatedGet('/cover-letters');

    print("API Response: $responseMap");

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(SavedCoverLetter.fromJson)
        .toList();
  }
  /// Calls GET /cover-letters/templates to get the list of templates
  Future<List<CoverLetterTemplate>> fetchTemplates() async {
    final responseMap = await AuthService.authenticatedGet('/cover-letters/templates');

    print("API Response (fetchTemplates): $responseMap");

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(CoverLetterTemplate.fromJson)
        .toList();
  }

  /// Calls GET /cover-letters/templates/:id to get the detail of a template
  Future<CoverLetterTemplate> fetchTemplateDetails(String id) async {
    final responseMap = await AuthService.authenticatedGet('/cover-letters/templates/$id');

    print("API Response (fetchTemplateDetails): $responseMap");

    final data = responseMap['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw 'Server returned no data for template ID: $id';
    }

    return CoverLetterTemplate.fromJson(data);
  }
}

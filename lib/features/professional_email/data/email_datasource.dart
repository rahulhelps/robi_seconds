import '../../../../core/services/auth_service.dart';
import '../domain/email_model.dart';

// ignore_for_file: avoid_print

/// EmailDatasource handles all Professional Email API calls.
/// All methods gracefully handle backend responses.
class EmailDatasource {
  /// Sends an email request to POST /email to create/save an email.
  /// Returns the saved [SavedEmail] object.
  Future<SavedEmail> createEmail(EmailModel model) async {
    final responseMap = await AuthService.authenticatedPost(
      '/email',
      model.toJson(),
    );

    print('[EmailDatasource] createEmail response: $responseMap');

    final data = responseMap['data'] as Map<String, dynamic>? ?? responseMap;
    if (data.containsKey('id') || data.containsKey('_id') || data.containsKey('subject')) {
      return SavedEmail.fromJson(data);
    }

    throw 'Server returned invalid data for email.';
  }

  /// Calls GET /email and returns a list of [SavedEmail].
  Future<List<SavedEmail>> fetchEmailHistory() async {
    try {
      final responseMap = await AuthService.authenticatedGet('/email');

      print('[EmailDatasource] fetchEmailHistory response: $responseMap');

      final rawData = responseMap['data'];
      if (rawData is! List) {
        return [];
      }

      return rawData
          .whereType<Map<String, dynamic>>()
          .map(SavedEmail.fromJson)
          .toList();
    } catch (e) {
      print('[EmailDatasource] fetchEmailHistory error: $e');
      return [];
    }
  }

  /// Calls GET /email/:id and returns a single [SavedEmail].
  Future<SavedEmail> getEmailDetails(String id) async {
    final responseMap = await AuthService.authenticatedGet('/email/$id');
    final data = responseMap['data'] as Map<String, dynamic>? ?? responseMap;
    return SavedEmail.fromJson(data);
  }

  /// Calls DELETE /email/:id to delete an email.
  Future<void> deleteEmail(String id) async {
    await AuthService.authenticatedDelete('/email/$id');
  }
}

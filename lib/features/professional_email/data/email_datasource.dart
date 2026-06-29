import '../../../../core/services/auth_service.dart';
import '../domain/email_model.dart';

// ignore_for_file: avoid_print

/// EmailDatasource handles all Professional Email API calls.
/// All methods gracefully handle backend unavailability.
class EmailDatasource {
  /// Sends an email request to POST /email to create/save an email.
  /// Returns the saved [SavedEmail] object.
  /// Throws gracefully — never crashes the app.
  Future<SavedEmail> createEmail(EmailModel model) async {
    final responseMap = await AuthService.authenticatedPost(
      '/email',
      model.toJson(),
    );

    print('[EmailDatasource] createEmail response: $responseMap');

    final data = responseMap['data'];
    if (data == null) {
      throw 'Server returned no data for email.';
    }

    if (data is Map<String, dynamic>) {
      return SavedEmail.fromJson(data);
    }

    throw 'Invalid email response format.';
  }

  /// Calls GET /email and returns a list of [SavedEmail].
  Future<List<SavedEmail>> fetchEmailHistory() async {
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
  }

  /// Calls GET /email/:id and returns a single [SavedEmail].
  Future<SavedEmail> getEmailDetails(String id) async {
    final responseMap = await AuthService.authenticatedGet('/email/$id');
    final data = responseMap['data'];
    if (data == null) throw 'Email details not found.';
    return SavedEmail.fromJson(data as Map<String, dynamic>);
  }

  /// Calls DELETE /email/:id to delete an email.
  Future<void> deleteEmail(String id) async {
    await AuthService.authenticatedDelete('/email/$id');
  }
}

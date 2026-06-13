import '../data/cover_letter_datasource.dart';
import '../domain/cover_letter_model.dart';

class CoverLetterRepository {
  final CoverLetterDatasource _datasource;

  CoverLetterRepository(this._datasource);

  /// Posts a cover letter to the server and returns the saved [SavedCoverLetter].
  Future<SavedCoverLetter> postCoverLetter(CoverLetterModel model) {
    return _datasource.postCoverLetter(model);
  }

  /// Fetches all cover letters from the server.
  Future<List<SavedCoverLetter>> fetchCoverLetters() {
    return _datasource.fetchCoverLetters();
  }

  /// Fetches all available cover letter templates from the server.
  Future<List<CoverLetterTemplate>> fetchTemplates() {
    return _datasource.fetchTemplates();
  }

  /// Fetches specific template details from the server.
  Future<CoverLetterTemplate> fetchTemplateDetails(String id) {
    return _datasource.fetchTemplateDetails(id);
  }
}

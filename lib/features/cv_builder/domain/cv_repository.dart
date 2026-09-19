import '../data/cv_datasource.dart';
import '../domain/cv_model.dart';
import '../domain/cv_list_item.dart';

class CvRepository {
  final CvDatasource _datasource;

  CvRepository(this._datasource);

  /// Submits the CV to the server and returns the saved CV's id.
  Future<String> generateCv(CvModel cv) async {
    return _datasource.generateCv(cv);
  }

  /// Fetches the list of all user CVs from GET /api/v1/cvs.
  Future<List<CvListItem>> fetchCvList() async {
    return _datasource.fetchCvList();
  }

  /// Deletes a CV by id.
  Future<void> deleteCv(String id) async {
    return _datasource.deleteCv(id);
  }

  /// Returns the full streaming URL for a given CV id.
  String buildViewUrl(String id) => _datasource.buildViewUrl(id);

  /// Returns the current Bearer access token (for PDF viewer auth header).
  Future<String?> getAccessToken() => _datasource.getAccessToken();

  /// Generates a CV using AI assistance.
  Future<Map<String, dynamic>> generateCvWithAi({
    required String jobTitle,
    required String industry,
    required String experienceLevel,
    required int yearsOfExperience,
    required List<String> keySkills,
    required String educationLevel,
    required String additionalDetails,
    String? templateId,
  }) => _datasource.generateCvWithAi(
    jobTitle: jobTitle,
    industry: industry,
    experienceLevel: experienceLevel,
    yearsOfExperience: yearsOfExperience,
    keySkills: keySkills,
    educationLevel: educationLevel,
    additionalDetails: additionalDetails,
    templateId: templateId,
  );
}

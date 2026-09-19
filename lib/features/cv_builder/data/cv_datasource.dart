import 'package:flutter/foundation.dart';
import '../../../../core/constants.dart';
import '../../../../core/services/auth_service.dart';
import '../domain/cv_model.dart';
import '../domain/cv_list_item.dart';

String get _baseUrl => ApiConstants.baseUrl;

class CvDatasource {
  Future<String> generateCv(CvModel cv) async {
    final payload = cv.toJson();
    final templateId = (payload['template_id'] as String?)?.trim().isNotEmpty == true
        ? (payload['template_id'] as String).trim()
        : cv.templateId.trim().isNotEmpty
            ? cv.templateId.trim()
            : null;

    final body = <String, dynamic>{
      'payload': payload,
    };
    if (templateId != null) {
      body['template_id'] = templateId;
    }

    final responseMap = await AuthService.authenticatedPost(
      '/cvs/generate',
      body,
    );

    debugPrint("API Response: $responseMap");

    final success = responseMap['success'] == true;
    final data = responseMap['data'] as Map<String, dynamic>?;

    if (success && data != null) {
      final String? cvId = data['id'] as String? ?? data['cvId'] as String?;

      if (cvId == null || cvId.isEmpty) {
        throw "CV ID missing from response";
      }

      debugPrint("CV ID: $cvId");
      return cvId;
    } else {
      throw responseMap['message']?.toString() ?? "Something went wrong";
    }
  }

  Future<List<CvListItem>> fetchCvList() async {
    final responseMap = await AuthService.authenticatedGet('/cvs');

    debugPrint("API Response: $responseMap");

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(CvListItem.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> fetchCv(String id) async {
    final responseMap = await AuthService.authenticatedGet('/cvs/$id');

    final success = responseMap['success'] == true;
    final data = responseMap['data'] as Map<String, dynamic>?;

    if (success && data != null) {
      return data;
    }

    throw responseMap['message']?.toString() ?? 'Failed to fetch CV';
  }

  Future<void> deleteCv(String id) async {
    await AuthService.authenticatedDelete('/cvs/$id');
  }

  Future<String?> getAccessToken() async {
    return AuthService.getAccessToken();
  }

  String buildViewUrl(String id) => '$_baseUrl/cvs/$id/view';

  Future<Map<String, dynamic>> generateCvWithAi({
    required String jobTitle,
    required String industry,
    required String experienceLevel,
    required int yearsOfExperience,
    required List<String> keySkills,
    required String educationLevel,
    required String additionalDetails,
    String? templateId,
  }) async {
    final body = {
      'template_id': templateId,
      'job_title': jobTitle,
      'industry': industry,
      'experience_level': experienceLevel,
      'years_of_experience': yearsOfExperience,
      'key_skills': keySkills,
      'education_level': educationLevel,
      'additional_details': additionalDetails,
    };

    final responseMap = await AuthService.authenticatedPost(
      '/cvs/ai-generate',
      body,
    );

    final success = responseMap['success'] == true;
    final data = responseMap['data'] as Map<String, dynamic>?;
    final cvId = responseMap['cvId'] as String?;

    if (success && data != null && cvId != null) {
      return {'cvId': cvId, 'data': data};
    }

    throw responseMap['message']?.toString() ?? 'Failed to generate CV with AI';
  }
}

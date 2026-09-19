import 'package:dio/dio.dart';
import '../network/api_client.dart';

class ContentRepository {
  ContentRepository._();

  static Map<String, dynamic>? _cachedTemplates;
  static Map<String, dynamic>? _cachedEducation;
  static Map<String, dynamic>? _cachedArticles;
  static Map<String, dynamic>? _cachedCategories;
  static Map<String, dynamic>? _cachedScholarships;
  static Map<String, dynamic>? _cachedConfig;

  static Future<Map<String, dynamic>> getTemplates({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTemplates != null) {
      return _cachedTemplates!;
    }

    try {
      final response = await ApiClient.dio.get('/v1/templates');
      final data = Map<String, dynamic>.from(response.data);
      _cachedTemplates = data;
      return data;
    } on DioException catch (e) {
      if (_cachedTemplates != null) return _cachedTemplates!;
      return {'data': []};
    }
  }

  static Future<Map<String, dynamic>> getEducation({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedEducation != null) {
      return _cachedEducation!;
    }

    try {
      final response = await ApiClient.dio.get('/v1/education');
      final data = Map<String, dynamic>.from(response.data);
      _cachedEducation = data;
      return data;
    } on DioException catch (e) {
      if (_cachedEducation != null) return _cachedEducation!;
      return {'levels': [], 'boards': [], 'groups': [], 'grading_scales': [], 'institutions': []};
    }
  }

  static Future<Map<String, dynamic>> getLearningArticles({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedArticles != null) {
      return _cachedArticles!;
    }

    try {
      final response = await ApiClient.dio.get('/v1/learning-articles');
      final data = Map<String, dynamic>.from(response.data);
      _cachedArticles = data;
      return data;
    } on DioException catch (e) {
      if (_cachedArticles != null) return _cachedArticles!;
      return {'data': []};
    }
  }

  static Future<Map<String, dynamic>> getLearningCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final response = await ApiClient.dio.get('/v1/learning-categories');
      final data = Map<String, dynamic>.from(response.data);
      _cachedCategories = data;
      return data;
    } on DioException catch (e) {
      if (_cachedCategories != null) return _cachedCategories!;
      return {'data': []};
    }
  }

  static Future<Map<String, dynamic>> getScholarships({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedScholarships != null) {
      return _cachedScholarships!;
    }

    try {
      final response = await ApiClient.dio.get('/v1/scholarships');
      final data = Map<String, dynamic>.from(response.data);
      _cachedScholarships = data;
      return data;
    } on DioException catch (e) {
      if (_cachedScholarships != null) return _cachedScholarships!;
      return {'data': []};
    }
  }

  static Future<Map<String, dynamic>> getAppConfig({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      final response = await ApiClient.dio.get('/v1/config');
      final data = Map<String, dynamic>.from(response.data);
      _cachedConfig = data;
      return data;
    } on DioException catch (e) {
      if (_cachedConfig != null) return _cachedConfig!;
      return {'data': {}};
    }
  }

  static Future<String?> getContentVersion() async {
    try {
      final config = await getAppConfig();
      final data = config['data'] as Map<String, dynamic>?;
      return data?['content_version'] as String?;
    } catch (e) {
      return null;
    }
  }

  static void clearCache() {
    _cachedTemplates = null;
    _cachedEducation = null;
    _cachedArticles = null;
    _cachedCategories = null;
    _cachedScholarships = null;
    _cachedConfig = null;
  }
}
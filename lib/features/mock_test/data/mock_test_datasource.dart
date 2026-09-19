import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../../../core/storage/token_manager.dart';
import '../domain/mock_test_model.dart';

class MockTestDatasource {
  const MockTestDatasource();

  Future<List<MockTestTopic>> fetchTopics() async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/topics'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final topics = (data['topics'] as List?) ?? [];
      return topics
          .whereType<Map<String, dynamic>>()
          .map(MockTestTopic.fromJson)
          .toList();
    }

    throw Exception('Failed to load topics: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> fetchDailyQuiz() async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/daily'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to load daily quiz: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> fetchHistory() async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to load history: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> fetchContext() async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/context'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to load context: ${response.statusCode}');
  }

  Future<List<dynamic>> fetchSuggested() async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/suggested'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['suggested'] as List?) ?? [];
    }

    throw Exception('Failed to load suggested: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> startMockTest({
    String? topic,
    String? difficulty,
    bool? continueSession,
  }) async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final body = <String, dynamic>{
      'topic': ?topic,
      'difficulty': ?difficulty,
      'continue_session': ?continueSession,
    };

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/start'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to start mock test: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> evaluateAnswer({
    required String sessionId,
    required String question,
    required List<String> options,
    required int selectedIndex,
    required int correctIndex,
    String? explanation,
  }) async {
    final headers = await TokenManager.getAccessToken() != null
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenManager.getAccessToken()}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/mock-test/evaluate'),
      headers: headers,
      body: jsonEncode({
        'session_id': sessionId,
        'question': question,
        'options': options,
        'selected_index': selectedIndex,
        'correct_index': correctIndex,
        'explanation': ?explanation,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to evaluate answer: ${response.statusCode}');
  }
}

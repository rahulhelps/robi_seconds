import 'mock_test_model.dart';

abstract class MockTestRepository {
  Future<List<MockTestTopic>> fetchTopics();
  Future<Map<String, dynamic>> fetchDailyQuiz();
  Future<Map<String, dynamic>> fetchHistory();
  Future<Map<String, dynamic>> fetchContext();
  Future<List<dynamic>> fetchSuggested();
  Future<Map<String, dynamic>> startMockTest({
    String? topic,
    String? difficulty,
    bool? continueSession,
  });

  Future<Map<String, dynamic>> evaluateAnswer({
    required String sessionId,
    required String question,
    required List<String> options,
    required int selectedIndex,
    required int correctIndex,
    String? explanation,
  });
}

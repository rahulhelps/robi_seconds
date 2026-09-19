import 'package:quickcvpro/features/mock_test/domain/mock_test_model.dart';
import 'package:quickcvpro/features/mock_test/domain/mock_test_repository.dart';
import 'package:quickcvpro/features/mock_test/data/mock_test_datasource.dart';

class MockTestRepositoryImpl implements MockTestRepository {
  final MockTestDatasource dataSource;

  const MockTestRepositoryImpl(this.dataSource);

  @override
  Future<List<MockTestTopic>> fetchTopics() async {
    return await dataSource.fetchTopics();
  }

  @override
  Future<Map<String, dynamic>> fetchDailyQuiz() async {
    return await dataSource.fetchDailyQuiz();
  }

  @override
  Future<Map<String, dynamic>> fetchHistory() async {
    return await dataSource.fetchHistory();
  }

  @override
  Future<Map<String, dynamic>> fetchContext() async {
    return await dataSource.fetchContext();
  }

  @override
  Future<List<dynamic>> fetchSuggested() async {
    return await dataSource.fetchSuggested();
  }

  @override
  Future<Map<String, dynamic>> startMockTest({
    String? topic,
    String? difficulty,
    bool? continueSession,
  }) async {
    return await dataSource.startMockTest(
      topic: topic,
      difficulty: difficulty,
      continueSession: continueSession,
    );
  }

  @override
  Future<Map<String, dynamic>> evaluateAnswer({
    required String sessionId,
    required String question,
    required List<String> options,
    required int selectedIndex,
    required int correctIndex,
    String? explanation,
  }) async {
    return await dataSource.evaluateAnswer(
      sessionId: sessionId,
      question: question,
      options: options,
      selectedIndex: selectedIndex,
      correctIndex: correctIndex,
      explanation: explanation,
    );
  }
}

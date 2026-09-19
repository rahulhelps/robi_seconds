import 'package:equatable/equatable.dart';
import '../../domain/mock_test_model.dart';

abstract class MockTestState extends Equatable {
  const MockTestState();

  @override
  List<Object> get props => [];
}

class MockTestInitial extends MockTestState {}

class MockTestLoading extends MockTestState {}

class MockTestTopicsLoaded extends MockTestState {
  final List<MockTestTopic> topics;

  const MockTestTopicsLoaded({required this.topics});

  @override
  List<Object> get props => [topics];
}

class MockTestHistoryLoaded extends MockTestState {
  final List<Map<String, dynamic>> attempts;

  const MockTestHistoryLoaded({required this.attempts});

  @override
  List<Object> get props => [attempts];
}

class MockTestDailyQuizLoaded extends MockTestState {
  final Map<String, dynamic> quiz;

  const MockTestDailyQuizLoaded({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

class MockTestSuggestedLoaded extends MockTestState {
  final List<dynamic> suggested;

  const MockTestSuggestedLoaded({required this.suggested});

  @override
  List<Object> get props => [suggested];
}

class MockTestQuestionLoaded extends MockTestState {
  final String sessionId;
  final MockTestQuestion question;
  final bool continued;

  const MockTestQuestionLoaded({
    required this.sessionId,
    required this.question,
    this.continued = false,
  });

  @override
  List<Object> get props => [sessionId, question, continued];
}

class MockTestAnswerEvaluated extends MockTestState {
  final String sessionId;
  final MockTestQuestion question;
  final int selectedIndex;
  final bool correct;
  final String explanation;
  final int score;
  final int total;

  const MockTestAnswerEvaluated({
    required this.sessionId,
    required this.question,
    required this.selectedIndex,
    required this.correct,
    required this.explanation,
    required this.score,
    required this.total,
  });

  @override
  List<Object> get props => [sessionId, question, selectedIndex, correct, explanation, score, total];
}

class MockTestCompleted extends MockTestState {
  final int score;
  final int total;

  const MockTestCompleted({required this.score, required this.total});

  @override
  List<Object> get props => [score, total];
}

class MockTestError extends MockTestState {
  final String message;

  const MockTestError(this.message);

  @override
  List<Object> get props => [message];
}

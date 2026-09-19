import 'package:equatable/equatable.dart';

abstract class MockTestEvent extends Equatable {
  const MockTestEvent();

  @override
  List<Object?> get props => [];
}

class StartMockTest extends MockTestEvent {
  final String? topic;
  final String? difficulty;
  final bool? continueSession;

  const StartMockTest({this.topic, this.difficulty, this.continueSession});

  @override
  List<Object?> get props => [topic, difficulty, continueSession];
}

class LoadTopics extends MockTestEvent {
  const LoadTopics();
}

class LoadHistory extends MockTestEvent {
  const LoadHistory();
}

class LoadDailyQuiz extends MockTestEvent {
  const LoadDailyQuiz();
}

class LoadSuggested extends MockTestEvent {
  const LoadSuggested();
}

class SubmitAnswer extends MockTestEvent {
  final String question;
  final List<String> options;
  final int selectedIndex;

  const SubmitAnswer({
    required this.question,
    required this.options,
    required this.selectedIndex,
  });

  @override
  List<Object> get props => [question, options, selectedIndex];
}

class ResetMockTest extends MockTestEvent {
  const ResetMockTest();
}

import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcvpro/features/mock_test/data/mock_test_datasource.dart';
import 'package:quickcvpro/features/mock_test/data/mock_test_repository_impl.dart';
import 'package:quickcvpro/features/mock_test/domain/mock_test_model.dart';
import 'package:quickcvpro/features/mock_test/domain/mock_test_repository.dart';
import 'package:quickcvpro/features/mock_test/presentation/bloc/mock_test_event.dart';
import 'package:quickcvpro/features/mock_test/presentation/bloc/mock_test_state.dart';

class MockTestBloc extends Bloc<MockTestEvent, MockTestState> {
  final MockTestRepository repository;
  MockTestSession? _session;

  MockTestBloc({MockTestRepository? repository})
      : repository = repository ?? MockTestRepositoryImpl(const MockTestDatasource()),
        super(MockTestInitial()) {
    on<LoadTopics>(_onLoadTopics);
    on<LoadHistory>(_onLoadHistory);
    on<LoadDailyQuiz>(_onLoadDailyQuiz);
    on<LoadSuggested>(_onLoadSuggested);
    on<StartMockTest>(_onStart);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<ResetMockTest>(_onReset);
  }

  Future<void> _onLoadTopics(
    LoadTopics event,
    Emitter<MockTestState> emit,
  ) async {
    emit(MockTestLoading());
    try {
      final topics = await repository.fetchTopics();
      emit(MockTestTopicsLoaded(topics: topics));
    } catch (e) {
      log('[MockTestBloc] load topics failed: $e');
      emit(MockTestError(e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<MockTestState> emit,
  ) async {
    emit(MockTestLoading());
    try {
      final result = await repository.fetchHistory();
      final attempts = (result['data'] as List?) ?? [];
      emit(MockTestHistoryLoaded(attempts: attempts.cast<Map<String, dynamic>>()));
    } catch (e) {
      log('[MockTestBloc] load history failed: $e');
      emit(MockTestError(e.toString()));
    }
  }

  Future<void> _onLoadDailyQuiz(
    LoadDailyQuiz event,
    Emitter<MockTestState> emit,
  ) async {
    emit(MockTestLoading());
    try {
      final quiz = await repository.fetchDailyQuiz();
      emit(MockTestDailyQuizLoaded(quiz: quiz));
    } catch (e) {
      log('[MockTestBloc] load daily quiz failed: $e');
      emit(MockTestError(e.toString()));
    }
  }

  Future<void> _onLoadSuggested(
    LoadSuggested event,
    Emitter<MockTestState> emit,
  ) async {
    emit(MockTestLoading());
    try {
      final suggested = await repository.fetchSuggested();
      emit(MockTestSuggestedLoaded(suggested: suggested));
    } catch (e) {
      log('[MockTestBloc] load suggested failed: $e');
      emit(MockTestError(e.toString()));
    }
  }

  Future<void> _onStart(
    StartMockTest event,
    Emitter<MockTestState> emit,
  ) async {
    emit(MockTestLoading());
    try {
      final result = await repository.startMockTest(
        topic: event.topic,
        difficulty: event.difficulty,
        continueSession: event.continueSession,
      );

      final continued = result['continued'] == true;

      if (continued) {
        final lastQuestionData = result['last_question'] as Map<String, dynamic>? ?? {};
        final question = MockTestQuestion.fromJson(lastQuestionData);
        final sessionId = (result['session_id'] as String?) ?? '';

        _session = MockTestSession(
          sessionId: sessionId,
          score: 0,
          total: 0,
          questions: [question],
        );

        emit(MockTestQuestionLoaded(
          sessionId: sessionId,
          question: question,
          continued: true,
        ));
        return;
      }

      final sessionId = (result['session_id'] as String?) ?? '';
      final questionData = result['question'] as Map<String, dynamic>? ?? {};
      final question = MockTestQuestion.fromJson(questionData);

      _session = MockTestSession(
        sessionId: sessionId,
        score: 0,
        total: 0,
        questions: [question],
      );

      emit(MockTestQuestionLoaded(sessionId: sessionId, question: question));
    } catch (e) {
      log('[MockTestBloc] start failed: $e');
      emit(MockTestError(e.toString()));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<MockTestState> emit,
  ) async {
    if (_session == null) {
      emit(const MockTestError('No active session'));
      return;
    }

    final question = _session!.questions.last;
    final correctIndex = question.correctIndex;
    final isCorrect = event.selectedIndex == correctIndex;

    try {
      final result = await repository.evaluateAnswer(
        sessionId: _session!.sessionId,
        question: question.question,
        options: question.options,
        selectedIndex: event.selectedIndex,
        correctIndex: correctIndex,
        explanation: question.explanation,
      );

      final newScore = _session!.score + (isCorrect ? 1 : 0);
      final newTotal = _session!.total + 1;

      _session = _session!.copyWith(
        score: newScore,
        total: newTotal,
      );

      emit(MockTestAnswerEvaluated(
        sessionId: _session!.sessionId,
        question: question,
        selectedIndex: event.selectedIndex,
        correct: isCorrect,
        explanation: (result['explanation'] as String?) ?? question.explanation,
        score: newScore,
        total: newTotal,
      ));
    } catch (e) {
      log('[MockTestBloc] evaluate failed: $e');
      emit(MockTestError(e.toString()));
    }
  }

  Future<void> _onReset(
    ResetMockTest event,
    Emitter<MockTestState> emit,
  ) async {
    _session = null;
    emit(MockTestInitial());
  }
}

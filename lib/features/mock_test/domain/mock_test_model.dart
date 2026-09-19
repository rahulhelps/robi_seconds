class MockTestQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  MockTestQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory MockTestQuestion.fromJson(Map<String, dynamic> json) {
    return MockTestQuestion(
      question: (json['question'] as String?) ?? '',
      options: (json['options'] as List?)?.map((e) => '$e').toList() ?? const [],
      correctIndex: (json['correct_index'] as int?) ?? 0,
      explanation: (json['explanation'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correct_index': correctIndex,
        'explanation': explanation,
      };
}

class MockTestSession {
  final String sessionId;
  final int score;
  final int total;
  final List<MockTestQuestion> questions;

  MockTestSession({
    required this.sessionId,
    required this.score,
    required this.total,
    required this.questions,
  });

  MockTestSession copyWith({
    String? sessionId,
    int? score,
    int? total,
    List<MockTestQuestion>? questions,
  }) {
    return MockTestSession(
      sessionId: sessionId ?? this.sessionId,
      score: score ?? this.score,
      total: total ?? this.total,
      questions: questions ?? this.questions,
    );
  }
}

class MockTestTopic {
  final String key;
  final String label;
  final String? description;

  MockTestTopic({required this.key, required this.label, this.description});

  factory MockTestTopic.fromJson(Map<String, dynamic> json) {
    return MockTestTopic(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class MockTestHistoryItem {
  final String id;
  final String sessionId;
  final String topic;
  final String? difficulty;
  final String question;
  final List<String> options;
  final int? selectedIndex;
  final int? correctIndex;
  final bool? isCorrect;
  final String? explanation;
  final String? respondedAt;
  final String createdAt;

  MockTestHistoryItem({
    required this.id,
    required this.sessionId,
    required this.topic,
    this.difficulty,
    required this.question,
    required this.options,
    this.selectedIndex,
    this.correctIndex,
    this.isCorrect,
    this.explanation,
    this.respondedAt,
    required this.createdAt,
  });

  factory MockTestHistoryItem.fromJson(Map<String, dynamic> json) {
    return MockTestHistoryItem(
      id: (json['id'] ?? json['session_id'] ?? '').toString(),
      sessionId: (json['session_id'] ?? '').toString(),
      topic: (json['topic'] ?? '').toString(),
      difficulty: json['difficulty'] as String?,
      question: (json['question'] ?? '').toString(),
      options: (json['options'] as List?)?.map((e) => '$e').toList() ?? const [],
      selectedIndex: json['selected_index'] as int?,
      correctIndex: json['correct_index'] as int?,
      isCorrect: json['is_correct'] as bool?,
      explanation: json['explanation'] as String?,
      respondedAt: json['responded_at'] as String?,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

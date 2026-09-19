import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/mock_test_bloc.dart';
import '../bloc/mock_test_event.dart';
import '../bloc/mock_test_state.dart';
import '../../domain/mock_test_model.dart';
import '../widgets/question_chat_bubble.dart';

class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MockTestBloc()..add(const LoadTopics()),
      child: const _MockTestView(),
    );
  }
}

class _MockTestView extends StatefulWidget {
  const _MockTestView();

  @override
  State<_MockTestView> createState() => _MockTestViewState();
}

class _MockTestViewState extends State<_MockTestView> {
  final ScrollController _scrollController = ScrollController();
  int _currentTab = 0;
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI Mock Test',
                              style: GoogleFonts.manrope(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF191C1D),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: () {
                              context.read<MockTestBloc>().add(const ResetMockTest());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        tabs: const [
                          Tab(text: 'Practice'),
                          Tab(text: 'History'),
                          Tab(text: 'Suggested'),
                        ],
                        labelColor: const Color(0xFF024D87),
                        unselectedLabelColor: const Color(0xFF6E7B6B),
                        indicatorColor: const Color(0xFF024D87),
                        onTap: (index) {
                          setState(() {
                            _currentTab = index;
                          });

                          if (index == 0) {
                            context.read<MockTestBloc>().add(const LoadTopics());
                          } else if (index == 1) {
                            context.read<MockTestBloc>().add(const LoadHistory());
                          } else if (index == 2) {
                            context.read<MockTestBloc>().add(const LoadSuggested());
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPracticeTab(context),
                      _buildHistoryTab(context),
                      _buildSuggestedTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeTab(BuildContext context) {
    return BlocConsumer<MockTestBloc, MockTestState>(
      listener: (context, state) {
        if (state is MockTestQuestionLoaded || state is MockTestAnswerEvaluated) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is MockTestLoading && _currentTab == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MockTestTopicsLoaded) {
          return _buildTopicSelector(context, state.topics);
        }

        if (state is MockTestQuestionLoaded) {
          return _buildChat(context, state.sessionId, state.question, null, state.continued);
        }

        if (state is MockTestAnswerEvaluated) {
          return _buildChat(
            context,
            state.sessionId,
            state.question,
            state,
            false,
          );
        }

        if (state is MockTestCompleted) {
          return _buildResult(context, state.score, state.total);
        }

        if (state is MockTestError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MockTestBloc>().add(const LoadTopics());
                    },
                    child: const Text('Back to Topics'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTopicSelector(BuildContext context, List<MockTestTopic> topics) {
    final groups = <String, List<MockTestTopic>>{
      'Government Jobs': topics.where((t) => t.label.toLowerCase().contains('bcs') || t.label.toLowerCase().contains('bank') || t.label.toLowerCase().contains('teacher')).toList(),
      'Private Sector': topics.where((t) => t.label.toLowerCase().contains('it') || t.label.toLowerCase().contains('marketing') || t.label.toLowerCase().contains('finance')).toList(),
      'Education': topics.where((t) => t.label.toLowerCase().contains('english') || t.label.toLowerCase().contains('math') || t.label.toLowerCase().contains('ict')).toList(),
      'General': topics.where((t) => t.label.toLowerCase().contains('general knowledge') || t.label.toLowerCase().contains('current affairs')).toList(),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Topic',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF191C1D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a category to start your AI-generated mock test.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6E7B6B),
            ),
          ),
          const SizedBox(height: 16),
          ...groups.entries.expand((entry) {
            if (entry.value.isEmpty) return <Widget>[];
            return [
              Text(
                entry.key,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF024D87),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: entry.value
                    .map(
                      (topic) => ActionChip(
                        label: Text(topic.label),
                        onPressed: () => _showDifficultyDialog(context, topic.label),
                        backgroundColor: const Color(0xFFF8F9FA),
                        labelStyle: GoogleFonts.inter(
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ];
          }),
        ],
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, String topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['easy', 'medium', 'hard']
              .map(
                (level) => ListTile(
                  title: Text(level.toUpperCase()),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    context.read<MockTestBloc>().add(
                          StartMockTest(
                            topic: topic,
                            difficulty: level,
                          ),
                        );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return BlocConsumer<MockTestBloc, MockTestState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is MockTestLoading && _currentTab == 1) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MockTestHistoryLoaded) {
          final attempts = state.attempts;

          if (attempts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No mock test history yet. Start your first test!'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attempts.length,
            itemBuilder: (context, index) {
              final attempt = attempts[index];
              final isCorrect = attempt['is_correct'] == true;
              final topic = attempt['topic'] ?? 'Unknown Topic';
              final question = (attempt['question'] ?? '').toString();
              final respondedAt = attempt['responded_at'] ?? attempt['created_at'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF024D87).withValues(alpha: 0.08),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isCorrect == true
                              ? Colors.green
                              : Colors.redAccent)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCorrect == true ? Icons.check_rounded : Icons.close_rounded,
                      color: isCorrect == true ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  title: Text(
                    topic,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      question.length > 60 ? '${question.substring(0, 60)}...' : question,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF3E4A3C),
                      ),
                    ),
                  ),
                  trailing: Text(
                    respondedAt != null ? _formatDate(respondedAt.toString()) : '',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6E7B6B),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSuggestedTab(BuildContext context) {
    return BlocConsumer<MockTestBloc, MockTestState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is MockTestLoading && _currentTab == 2) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MockTestSuggestedLoaded) {
          final suggested = state.suggested;

          if (suggested.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No suggestions yet. Take a few tests first!'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suggested.length,
            itemBuilder: (context, index) {
              final item = suggested[index] as Map<String, dynamic>;
              final label = (item['label'] ?? '') as String;
              final description = (item['description'] ?? '') as String;
              final reason = (item['reason'] ?? '') as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF024D87).withValues(alpha: 0.08),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description.isNotEmpty)
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF3E4A3C),
                            ),
                          ),
                        if (reason.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              reason,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF024D87),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onTap: () {
                    context.read<MockTestBloc>().add(
                          StartMockTest(
                            topic: label,
                            difficulty: 'medium',
                          ),
                        );
                  },
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.tryParse(iso);
      if (date == null) return '';
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${date.day}/${date.month}/${date.year}';
    } on Exception {
      return '';
    }
  }

  Widget _buildChat(
    BuildContext context,
    String sessionId,
    MockTestQuestion question,
    MockTestAnswerEvaluated? evaluated,
    bool continued,
  ) {
    final hasAnswered = evaluated != null;

    return Column(
      children: [
        if (continued)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF024D87).withValues(alpha: 0.1),
            child: Text(
              'Continuing from your previous session...',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF024D87),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                QuestionChatBubble(
                  text: question.question,
                  isUser: false,
                  showOptions: true,
                  options: question.options,
                  selectedIndex: evaluated?.selectedIndex,
                  correctIndex: question.correctIndex,
                  onOptionSelected: hasAnswered
                      ? null
                      : () async {
                          final selected = await _showOptionsBottomSheet(
                            context,
                            question.options,
                          );
                          if (selected != null && mounted) {
                            setState(() {
                              _selectedOptionIndex = selected;
                            });
                          }
                        },
                ),
                if (_selectedOptionIndex != null && !hasAnswered) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<MockTestBloc>().add(
                                  SubmitAnswer(
                                    question: question.question,
                                    options: question.options,
                                    selectedIndex: _selectedOptionIndex!,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF024D87),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Check Answer',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (hasAnswered) ...[
                  QuestionChatBubble(
                    text: evaluated.correct
                        ? 'Correct! 🎉'
                        : 'Incorrect. The correct answer is: ${question.options[question.correctIndex]}',
                    isUser: true,
                  ),
                  if (question.explanation.isNotEmpty)
                    QuestionChatBubble(
                      text: 'Explanation: ${question.explanation}',
                      isUser: false,
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: ${evaluated.score}/${evaluated.total}',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF024D87),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                context.read<MockTestBloc>().add(
                                      StartMockTest(
                                        topic: null,
                                        difficulty: 'medium',
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Next'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                context.read<MockTestBloc>().add(const ResetMockTest());
                              },
                              icon: const Icon(Icons.exit_to_app),
                              label: const Text('Exit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<int?> _showOptionsBottomSheet(
    BuildContext context,
    List<String> options,
  ) async {
    return await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (ctx, index) {
            return ListTile(
              title: Text(options[index]),
              onTap: () => Navigator.pop(ctx, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, int score, int total) {
    final percentage = total > 0 ? ((score / total) * 100).round() : 0;
    final isGood = percentage >= 70;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isGood ? 'Great Job!' : 'Keep Practicing!',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGood ? const Color(0xFF024D87).withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.manrope(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: isGood ? const Color(0xFF024D87) : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You scored $score out of $total',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0xFF6E7B6B),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.read<MockTestBloc>().add(const ResetMockTest());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF024D87),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
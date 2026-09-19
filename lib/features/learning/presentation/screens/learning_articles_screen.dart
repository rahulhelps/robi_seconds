import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../../core/services/backend_service.dart';
import '../../../../../core/widgets/custom_gradient_header.dart';

bool _isBangla(String? text) {
  if (text == null || text.isEmpty) return false;
  final banglaRegex = RegExp(r'[\u0980-\u09FF]');
  return banglaRegex.hasMatch(text);
}

TextStyle _titleStyle(String? title) {
  if (_isBangla(title)) {
    return GoogleFonts.notoSerifBengali(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF191C1D),
    );
  }
  return GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF191C1D),
  );
}

TextStyle _subtitleStyle(String? title) {
  if (_isBangla(title)) {
    return GoogleFonts.notoSerifBengali(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF024D87),
    );
  }
  return GoogleFonts.inter(
    fontSize: 14,
    color: const Color(0xFF024D87),
    fontWeight: FontWeight.w500,
  );
}

class LearningArticlesScreen extends StatefulWidget {
  const LearningArticlesScreen({super.key});

  @override
  State<LearningArticlesScreen> createState() => _LearningArticlesScreenState();
}

class _LearningArticlesScreenState extends State<LearningArticlesScreen> {
  final BackendService _backendService = BackendService();
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final articles = await _backendService.getLearningArticles();
    if (mounted) {
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    }
  }

  void _showArticle(BuildContext context, dynamic article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article['title'] ?? '',
                      style: _titleStyle(article['title']),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: HtmlWidget(article['content'] ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            const CustomGradientHeader(
              title: 'Career Advice',
              subtitle: 'Learn how to boost your career prospects',
              badgeText: 'Articles',
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _articles.isEmpty
                      ? const Center(child: Text('No articles found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: _articles.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final article = _articles[index];
                            return InkWell(
                              onTap: () => _showArticle(context, article),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['title'] ?? 'Untitled',
                                      style: _titleStyle(article['title']),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Read more about ${article['title'] ?? 'this topic'}...',
                                      style: _subtitleStyle(article['title']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

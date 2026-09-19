import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIntroScreen extends StatefulWidget {
  const AppIntroScreen({super.key});

  @override
  State<AppIntroScreen> createState() => _AppIntroScreenState();
}

class _AppIntroScreenState extends State<AppIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'QuickCV Pro এ স্বাগতম',
      'subtitle': 'Build Your Future — One Page at a Time',
      'description': 'AI-powered CV builder, cover letter, SOP, and professional email maker designed for Bangladeshi job seekers.',
      'icon': Icons.auto_awesome_rounded,
      'color': const Color(0xFF024D87),
      'bgColor': const Color(0xFFEFF6FF),
    },
    {
      'title': 'AI CV Generator',
      'subtitle': 'AI CV তৈরি করুন সেকেন্ডে',
      'description': 'Just enter your job title, skills, and experience. AI will create a professional, ATS-ready CV in seconds.',
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFF7C3AED),
      'bgColor': const Color(0xFFF5F3FF),
    },
    {
      'title': '32+ Professional Templates',
      'subtitle': 'বিভিন্ন পেশাগত টেমপ্লেট',
      'description': 'Choose from 32+ professionally designed templates for every industry — IT, Banking, Medical, Legal, Academic, and more.',
      'icon': Icons.palette_rounded,
      'color': const Color(0xFF059669),
      'bgColor': const Color(0xFFECFDF5),
    },
    {
      'title': 'Cover Letter & SOP Maker',
      'subtitle': 'কভার লিটার ও SOP তৈরি করুন',
      'description': 'Generate professional cover letters and Statements of Purpose with AI. Perfect for job applications and university admissions.',
      'icon': Icons.mail_rounded,
      'color': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFFFBEB),
    },
    {
      'title': 'Professional Email Generator',
      'subtitle': 'পেশাদার ইমেইল লিখুন',
      'description': 'Write polished professional emails for job applications, follow-ups, resignations, and networking in seconds.',
      'icon': Icons.email_rounded,
      'color': const Color(0xFF0284C7),
      'bgColor': const Color(0xFFF0F9FF),
    },
    {
      'title': 'Mock Tests & Interview Prep',
      'subtitle': 'মক টেস্ট ও ইন্টারভিউ প্রিপারেশন',
      'description': 'Practice with 25+ mock test topics including BCS, Bank, IT, and more. Get interview tips and career guidance in Bangla and English.',
      'icon': Icons.quiz_rounded,
      'color': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFFEF2F2),
    },
    {
      'title': 'Job Portals & Career Advice',
      'subtitle': 'চাকরি ও ক্যারিয়ার গাইড',
      'description': 'Access 36+ Bangladeshi job portals, exam results, scholarships, and career articles — all inside the app.',
      'icon': Icons.work_rounded,
      'color': const Color(0xFF4F46E5),
      'bgColor': const Color(0xFFEEF2FF),
    },
    {
      'title': 'Ready to Start?',
      'subtitle': 'আজই শুরু করুন',
      'description': 'Join thousands of Bangladeshi professionals who are building their careers with QuickCV Pro.',
      'icon': Icons.rocket_launch_rounded,
      'color': const Color(0xFF00B140),
      'bgColor': const Color(0xFFF0FDF4),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
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
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: slide['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: (slide['color'] as Color).withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              slide['icon'] as IconData,
                              size: 64,
                              color: slide['color'] as Color,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            slide['title'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF191C1D),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          if (slide['subtitle'] != null)
                            Text(
                              slide['subtitle'] as String,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            slide['description'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: const Color(0xFF3E4A3C),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _completeOnboarding();
                            }
                          },
                          child: Text(
                            _currentPage == 0 ? 'Skip' : 'Back',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(_slides.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF024D87)
                                    : const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _slides.length - 1) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF024D87),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

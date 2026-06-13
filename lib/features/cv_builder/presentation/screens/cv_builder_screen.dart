import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/cv_bloc.dart';
import 'package:quickcvpro/features/profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../../core/widgets/no_internet_screen.dart';

import 'cv_steps/step_career_objective.dart';
import 'cv_steps/step_personal_profile.dart';
import 'cv_steps/step_education.dart';
import 'cv_steps/step_skills.dart';
import 'cv_steps/step_work_experience.dart';
import 'cv_steps/step_languages.dart';
import 'cv_steps/step_review_submit.dart';
import 'pdf_preview_screen.dart';

/// Master multi-step CV builder screen.
/// Expects [CvBuilderBloc] to already be in the widget tree.
class CvBuilderScreen extends StatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const _stepTitles = [
    'Career Objective',
    'Personal Profile',
    'Education',
    'Skills',
    'Work Experience',
    'Languages',
    'Review & Submit',
  ];

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CvBloc, CvState>(
      listener: (context, state) {
        if (state is CvLoaded && state.cvId != null) {
          // Refresh profile data (CV count and history)
          print("CV created → refreshing profile");
          context.read<ProfileBloc>().add(const FetchProfile(forceNetwork: true));

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfPreviewScreen.fromId(
                cvId: state.cvId!,
                bearerToken: state.token ?? '',
              ),
            ),
          );
        } else if (state is CvError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFBA1A1A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          final isOffline = connectivityState is ConnectivityOffline;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF191C1D)),
                onPressed: () => _currentStep == 0
                    ? Navigator.pop(context)
                    : _prevStep(),
              ),
              title: Text(
                _stepTitles[_currentStep],
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF191C1D),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: _StepProgressBar(
                  current: _currentStep,
                  total: _stepTitles.length,
                ),
              ),
            ),
            body: isOffline
                ? NoInternetScreen(
                    onRetry: () {}, // Handled by connectivity bloc auto reload seamlessly when connection restores
                  )
                : PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StepCareerObjective(onNext: _nextStep),
                      StepPersonalProfile(onNext: _nextStep),
                      StepEducation(onNext: _nextStep),
                      StepSkills(onNext: _nextStep),
                      StepWorkExperience(onNext: _nextStep),
                      StepLanguages(onNext: _nextStep),
                      const StepReviewSubmit(),
                    ],
                  ),
          ),
          );
        },
      ),
    );
  }
}

// ── Progress bar indicator ────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _StepProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (current + 1) / total,
      minHeight: 4,
      backgroundColor: const Color(0xFFE1E3E4),
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF024D87)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/template_gallery_bloc.dart';
import '../bloc/cv_bloc.dart';
import '../widgets/gallery_hero_section.dart';
import '../widgets/gallery_filters.dart';
import '../../../../core/widgets/custom_gradient_header.dart';
import '../widgets/template_grid.dart';
import '../widgets/career_insights_callout.dart';
import '../../domain/cv_repository.dart';
import 'cv_builder_screen.dart';
import 'ai_cv_generator_screen.dart';

import '../../../../core/services/backend_service.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TemplateGalleryBloc(backendService: BackendService())..add(LoadTemplates())),
        BlocProvider(create: (context) => CvBloc(context.read<CvRepository>())),
      ],
      child: const _TemplateGalleryView(),
    );
  }
}

class _TemplateGalleryView extends StatelessWidget {
  const _TemplateGalleryView();

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
              title: 'Choose Your Layout',
              subtitle: 'Select a professional template for your CV',
              badgeText: '12 Templates',
            ),
            Expanded(
              child: BlocListener<TemplateGalleryBloc, TemplateGalleryState>(
                listener: (context, state) {
                  if (state is TemplateAllowed) {
                    context.read<CvBloc>().add(
                      CvSetTemplateId(state.templateId.toString()),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CvBloc>(),
                          child: const CvBuilderScreen(),
                        ),
                      ),
                    );
                  } else if (state is TemplateBlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Premium feature. Please upgrade to use this template.',
                        ),
                        backgroundColor: const Color(0xFFBA1A1A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  } else if (state is TemplateError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: const Color(0xFFBA1A1A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          GalleryHeroSection(),
                          SizedBox(height: 32),
                          _AiGenerateBanner(),
                          SizedBox(height: 48),
                          GalleryFilters(),
                          SizedBox(height: 48),
                          TemplateGrid(),
                          SizedBox(height: 64),
                          CareerInsightsCallout(),
                        ],
                      ),
                    ),
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

class _AiGenerateBanner extends StatelessWidget {
  const _AiGenerateBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF024D87), Color(0xFF28A745)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF024D87).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate CV with AI',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Describe your career and let AI build a professional, ATS-ready CV in seconds.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CvBloc>(),
                    child: const AiCvGeneratorScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: Text(
              'Try AI',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF024D87),
            ),
          ),
        ],
      ),
    );
  }
}

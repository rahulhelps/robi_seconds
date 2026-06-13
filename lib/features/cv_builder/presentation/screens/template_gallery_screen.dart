import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/template_gallery_bloc.dart';
import '../bloc/cv_bloc.dart';
import '../widgets/gallery_hero_section.dart';
import '../widgets/gallery_filters.dart';
import '../widgets/template_gallery_top_bar.dart';
import '../widgets/template_grid.dart';
import '../widgets/career_insights_callout.dart';
import '../../domain/cv_repository.dart';
import 'cv_builder_screen.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TemplateGalleryBloc()),
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
        body: SafeArea(
        child: Column(
          children: [
            const TemplateGalleryTopBar(),
            Expanded(
              child: BlocListener<TemplateGalleryBloc, TemplateGalleryState>(
                listener: (context, state) {
                  if (state is TemplateAllowed) {
                    // Save selected templateId to CvBloc before navigating
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
    ),
    );
  }
}

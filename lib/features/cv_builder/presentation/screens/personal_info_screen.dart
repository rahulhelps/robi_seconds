import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/personal_info/personal_info_bloc.dart';
import '../widgets/progress_stepper.dart';
import '../widgets/personal_info_form.dart';
import '../widgets/bento_options.dart';
import '../widgets/profile_insight_sidebar.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalInfoBloc(),
      child: const _PersonalInfoView(),
    );
  }
}

class _PersonalInfoView extends StatelessWidget {
  const _PersonalInfoView();

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
      // Top bar usually sits in Dashboard or navigation shell
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1024),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProgressStepper(),
                  const SizedBox(height: 48),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 1024;
                      return Flex(
                        direction: isDesktop ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: isDesktop ? 8 : 0,
                            child: const _MainFormContent(),
                          ),
                          if (isDesktop) const SizedBox(width: 32),
                          if (isDesktop)
                            const Expanded(
                              flex: 4,
                              child: ProfileInsightSidebar(),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _MainFormContent extends StatelessWidget {
  const _MainFormContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Craft your Identity.',
          style: GoogleFonts.manrope(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF191C1D),
          ).copyWith(
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's start with the basics. Your professional introduction begins here.",
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF3E4A3C),
          ),
        ),
        const SizedBox(height: 32),
        const PersonalInfoForm(),
        const SizedBox(height: 24),
        const BentoOptions(),
        const SizedBox(height: 32),
        const _ActionButtons(),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 600;
        final continueButton = Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF024D87), Color(0xFF28A745)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF024D87).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<PersonalInfoBloc>().add(ContinueClicked());
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                child: Center(
                  child: Text(
                    'Continue to Education',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        return Flex(
          direction: isVertical ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isVertical) continueButton else Expanded(child: continueButton),
            if (isVertical) const SizedBox(height: 16) else const SizedBox(width: 16),
            Expanded(
              flex: isVertical ? 0 : 1,
              child: TextButton(
                onPressed: () {
                  context.read<PersonalInfoBloc>().add(SaveDraftClicked());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  'Save as Draft',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E4A3C),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/cv_bloc.dart';

class StepCareerObjective extends StatelessWidget {
  final VoidCallback onNext;
  const StepCareerObjective({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'What drives your career?',
      subtitle: 'Write a short objective that summarises your professional goals.',
      onNext: onNext,
      child: _CareerObjectiveField(),
    );
  }
}

class _CareerObjectiveField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        return TextFormField(
          maxLines: 6,
          initialValue: state.model.careerObjective,
          style: GoogleFonts.inter(color: const Color(0xFF191C1D)),
          decoration: InputDecoration(
            hintText:
                'e.g. A results-driven software engineer with 3+ years of experience building scalable web applications...',
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            errorText: state.showErrors && state.model.careerObjective.trim().isEmpty ? 'Required' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDCAB9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF024D87), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (v) =>
              context.read<CvBloc>().add(CvUpdateCareerObjective(v)),
        );
      },
    );
  }
}

// ── Shared step scaffold ──────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                    fontSize: 15, color: const Color(0xFF3E4A3C)),
              ),
              const SizedBox(height: 32),
              child,
              const SizedBox(height: 32),
              _NextButton(onNext: onNext),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onNext;
  const _NextButton({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final isSubmitting = state is CvLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF024D87),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}


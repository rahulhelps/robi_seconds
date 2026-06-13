import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/cv_bloc.dart';

/// Final step — shows a summary and triggers the API call.
class StepReviewSubmit extends StatelessWidget {
  const StepReviewSubmit({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final cv = state.model;
        final isSubmitting = state is CvLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review & Submit',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Everything looks good? Submit to generate your PDF.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF3E4A3C),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summary cards
                  _SummaryRow('Template ID', cv.templateId),
                  _SummaryRow(
                    'Career Objective',
                    cv.careerObjective.isEmpty
                        ? '—'
                        : cv.careerObjective,
                  ),
                  _SummaryRow(
                    'Education entries',
                    '${cv.education.length}',
                  ),
                  _SummaryRow(
                    'Skill categories',
                    '${cv.skills.length}',
                  ),
                  _SummaryRow(
                    'Work experiences',
                    '${cv.workExperience.length}',
                  ),
                  _SummaryRow('Languages', '${cv.languages.length}'),

                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () =>
                          context.read<CvBloc>().add(
                            GenerateCV(),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF024D87),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        'Generate My CV',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E3E4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3E4A3C),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF191C1D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

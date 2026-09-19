import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';

class StepCareerObjective extends StatelessWidget {
  final VoidCallback onNext;
  const StepCareerObjective({super.key, required this.onNext});

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
              const CvStepHeader(
                title: 'Career Objective',
                subtitle:
                    'Write a compelling summary that highlights your key strengths and professional ambition.',
                icon: Icons.flag_rounded,
              ),
              const _CareerObjectiveField(),
              const SizedBox(height: 32),
              CvNextButton(onNext: onNext),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareerObjectiveField extends StatelessWidget {
  const _CareerObjectiveField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final hasError = state.showErrors && state.model.careerObjective.trim().isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Objective Statement',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  ' *',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53E3E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 7,
              initialValue: state.model.careerObjective,
              style: GoogleFonts.inter(
                color: const Color(0xFF1A202C),
                fontSize: 14,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g. A passionate and results-oriented professional with a strong track record of success, seeking to contribute technical expertise and innovative problem-solving skills in a forward-thinking organization...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFFA0AEC0),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: hasError ? const Color(0xFFFFF5F5) : const Color(0xFFF7FAFC),
                errorText: hasError ? 'Career objective is required' : null,
                errorStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFE53E3E),
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: hasError ? const Color(0xFFFEB2B2) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: hasError ? const Color(0xFFE53E3E) : const Color(0xFF024D87),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
              onChanged: (v) =>
                  context.read<CvBloc>().add(CvUpdateCareerObjective(v)),
            ),
          ],
        );
      },
    );
  }
}

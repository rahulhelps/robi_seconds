import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/cv_bloc.dart';
import '../../../data/cv_pdf_generator.dart';
import '../pdf_preview_screen.dart';

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
                    'Review your details before generating your CV.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF3E4A3C),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _SectionHeader('Personal Information'),
                  _DetailRow('Name', cv.personalInfo.name),
                  _DetailRow('Email', cv.personalInfo.email),
                  _DetailRow('Phone', cv.personalInfo.phone),
                  _DetailRow('Address', cv.personalInfo.address.isEmpty ? '—' : cv.personalInfo.address),

                  const SizedBox(height: 16),
                  _SectionHeader('Personal Profile'),
                  _DetailRow('Father\'s Name', cv.personalProfile.fatherName),
                  _DetailRow('Date of Birth', cv.personalProfile.dateOfBirth),
                  _DetailRow('Nationality', cv.personalProfile.nationality),
                  _DetailRow('Marital Status', cv.personalProfile.maritalStatus),
                  _DetailRow('Gender', cv.personalProfile.gender),
                  _DetailRow('Strength', cv.personalProfile.strength),
                  _DetailRow('Hobbies', cv.personalProfile.hobbies),

                  const SizedBox(height: 16),
                  _SectionHeader('Career Objective'),
                  _DetailRow('', cv.careerObjective.isEmpty ? '—' : cv.careerObjective),

                  const SizedBox(height: 16),
                  _SectionHeader('Education'),
                  if (cv.education.isEmpty)
                    _DetailRow('', 'No education entries added')
                  else
                    ...cv.education.asMap().entries.map((entry) {
                      final i = entry.key;
                      final edu = entry.value;
                      final year = edu.passingYear.isNotEmpty ? edu.passingYear : edu.endDate;
                      return _DetailCard(
                        title: edu.degree.isNotEmpty ? '${edu.degree} (${year.isNotEmpty ? year : '#${i + 1}'})' : 'Education #${i + 1}',
                        children: [
                          _DetailRow('Level / Degree', edu.degree),
                          _DetailRow('Institution', edu.institution),
                          if (edu.board.isNotEmpty)
                            _DetailRow('Board / University', edu.board),
                          if (edu.fieldOfStudy.isNotEmpty)
                            _DetailRow('Group / Major', edu.fieldOfStudy),
                          if (year.isNotEmpty)
                            _DetailRow('Passing Year', year),
                          if (edu.result.isNotEmpty)
                            _DetailRow('Result / GPA', edu.result),
                        ],
                      );
                    }),

                  const SizedBox(height: 16),
                  _SectionHeader('Skills'),
                  if (cv.skills.isEmpty)
                    _DetailRow('', 'No skills added')
                  else
                    ...cv.skills.asMap().entries.map((entry) {
                      final i = entry.key;
                      final skill = entry.value;
                      return _DetailCard(
                        title: 'Category #${i + 1}',
                        children: [
                          _DetailRow('Category', skill.category),
                          _DetailRow('Skills', skill.skills.join(', ')),
                        ],
                      );
                    }),

                  const SizedBox(height: 16),
                  _SectionHeader('Work Experience'),
                  if (cv.workExperience.isEmpty)
                    _DetailRow('', 'No work experience added')
                  else
                    ...cv.workExperience.asMap().entries.map((entry) {
                      final i = entry.key;
                      final exp = entry.value;
                      return _DetailCard(
                        title: 'Experience #${i + 1}',
                        children: [
                          _DetailRow('Company', exp.company),
                          _DetailRow('Position', exp.position),
                          _DetailRow('Start Date', exp.startDate),
                          _DetailRow('End Date', exp.endDate),
                          if (exp.description.isNotEmpty)
                            _DetailRow('Description', exp.description),
                          if (exp.bullets.isNotEmpty)
                            _DetailRow('Highlights', exp.bullets.join('\n')),
                        ],
                      );
                    }),

                  const SizedBox(height: 16),
                  _SectionHeader('Languages'),
                  if (cv.languages.isEmpty)
                    _DetailRow('', 'No languages added')
                  else
                    ...cv.languages.asMap().entries.map((entry) {
                      final i = entry.key;
                      final lang = entry.value;
                      return _DetailRow(
                        '${i + 1}. ${lang.language}',
                        lang.proficiency,
                      );
                    }),

                  const SizedBox(height: 32),

                  // ── Action Buttons ─────────────────────────────────────────
                  Row(
                    children: [
                      // Live Preview Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final pdfBytes = await CvPdfGenerator().generatePdf(cv);
                              if (!context.mounted) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfPreviewScreen.fromBytes(
                                    pdfBytes: pdfBytes,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to generate preview: $e'),
                                  backgroundColor: const Color(0xFFBA1A1A),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          label: Text(
                            'Live Preview',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF024D87),
                            side: const BorderSide(color: Color(0xFF024D87), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Generate My CV Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () => context.read<CvBloc>().add(
                                    const GenerateCV(),
                                  ),
                          icon: isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined, size: 20),
                          label: Text(
                            isSubmitting ? 'Generating...' : 'Save & Build',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF024D87),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF024D87),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E3E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E4A3C),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
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

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E3E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF024D87),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../cv_builder/presentation/screens/cv_list_screen.dart';
import '../../../cover_letter/presentation/screens/cover_letter_list_screen.dart';
import '../../../sop/presentation/screens/sop_list_screen.dart';
import '../../../professional_email/presentation/screens/email_list_screen.dart';

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        int cvCount = 4;
        int coverCount = 3;
        int sopCount = 2;
        int emailCount = 5;

        if (state is ProfileLoaded) {
          cvCount = state.cvCount;
          coverCount = state.coverLetterCount;
          sopCount = state.sopCount;
          emailCount = state.emailCount;
        }

        return Row(
          children: [
            // Pill 1: CVs
            Expanded(
              child: _StatPill(
                count: cvCount,
                label: 'CVs',
                accentColor: const Color(0xFF4F46E5),
                bgColor: const Color(0xFFEEF2FF),
                icon: Icons.description_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CvListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Pill 2: Letters
            Expanded(
              child: _StatPill(
                count: coverCount,
                label: 'Letters',
                accentColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                icon: Icons.mail_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoverLetterListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Pill 3: SOPs
            Expanded(
              child: _StatPill(
                count: sopCount,
                label: 'SOPs',
                accentColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
                icon: Icons.school_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SopListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Pill 4: Emails
            Expanded(
              child: _StatPill(
                count: emailCount,
                label: 'Emails',
                accentColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
                icon: Icons.mark_email_read_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailListScreen()),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final int count;
  final String label;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;
  final VoidCallback onTap;

  const _StatPill({
    required this.count,
    required this.label,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

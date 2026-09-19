import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/screens/profile_settings_screen.dart';

class ProfileQuickCard extends StatelessWidget {
  const ProfileQuickCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        int completion = 92;
        String tier = 'Strong';
        String advice = 'Ready for Top Multinational & Remote Jobs';

        if (state is ProfileLoaded) {
          completion = state.completionPercentage;
          if (completion >= 80) {
            tier = 'Strong';
            advice = 'Ready for Top Multinational & Remote Jobs';
          } else if (completion >= 50) {
            tier = 'Good';
            advice = 'Add skills & social links to reach 90%+';
          } else {
            tier = 'Getting Started';
            advice = 'Complete basic info & education to stand out';
          }
        }

        final factor = (completion / 100.0).clamp(0.05, 1.0);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileSettingsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Percentage Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Profile Strength',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$completion% ($tier)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFDE047),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rounded Progress Track & Bar
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: factor,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFFDE047)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle Advice & Edit Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        advice,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFDE047),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFFDE047),
                          size: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

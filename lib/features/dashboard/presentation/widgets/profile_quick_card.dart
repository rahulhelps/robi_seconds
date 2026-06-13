import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcvpro/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickcvpro/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class ProfileQuickCard extends StatelessWidget {
  const ProfileQuickCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String phoneDisplay = '...';
        if (state is ProfileLoaded) {
          final p = state.phoneNumber;
          if (p.length >= 7) {
            phoneDisplay = '${p.substring(0, 4)}****${p.substring(p.length - 3)}';
          } else {
            phoneDisplay = p;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Avatar + info row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF024D87),
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phoneDisplay,
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verified Profile',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF3E4A3C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Edit Profile button
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.read<DashboardBloc>().add(
                          const DashboardNavTabChanged(DashboardNavIndex.profile),
                        );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF024D87),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF024D87), size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

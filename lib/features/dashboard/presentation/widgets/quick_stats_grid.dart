import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcvpro/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickcvpro/features/cv_builder/presentation/screens/cv_list_screen.dart';
import 'package:quickcvpro/features/cover_letter/presentation/screens/cover_letter_list_screen.dart';
import 'package:quickcvpro/features/sop/presentation/screens/sop_list_screen.dart';
import 'package:quickcvpro/features/sop/presentation/bloc/sop_bloc.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';

// Model for each stat tile
class _StatItem {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });
}

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String cvCount = '0';
        String coverLetterCount = '0';
        String sopCount = '0';
        if (profileState is ProfileLoaded) {
          cvCount = profileState.cvCount.toString();
          coverLetterCount = profileState.coverLetterCount.toString();
          // sopCount will be dynamically obtained from SopBloc below
          print("Dashboard CoverLetterCount: $coverLetterCount");
        }

        return BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            final isOffline = connectivityState is ConnectivityOffline;

            final stats = [
              _StatItem(
                icon: Icons.mail_lock_outlined,
                iconColor: const Color(0xFF024D87),
                value: coverLetterCount,
                label: 'COVER LETTERS',
                onTap: () {
                  final state = context.read<ConnectivityBloc>().state;
                  if (state is ConnectivityOffline) {
                    print("QuickStatsGrid: Offline blocked");
                    _showNoInternetSnackbar(context);
                    return;
                  }
                  
                  print("Navigating to CoverLetter list");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CoverLetterListScreen(),
                    ),
                  );
                },
              ),
              _StatItem(
                icon: Icons.download_outlined,
                iconColor: const Color(0xFF51B1E1),
                value: cvCount,
                label: 'CVs Downloaded',
                onTap: () {
                  final state = context.read<ConnectivityBloc>().state;
                  if (state is ConnectivityOffline) {
                    print("QuickStatsGrid: Offline blocked");
                    _showNoInternetSnackbar(context);
                    return;
                  }

                  print("QuickStatsGrid: Online navigation allowed");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CvListScreen(),
                    ),
                  );
                },
              ),
              _StatItem(
                icon: Icons.edit_document,
                iconColor: const Color(0xFF10B981),
                value: sopCount,
                label: 'SOPs Created',
                onTap: () {
                  final state = context.read<ConnectivityBloc>().state;
                  if (state is ConnectivityOffline) {
                    print("QuickStatsGrid: Offline blocked");
                    _showNoInternetSnackbar(context);
                    return;
                  }

                  print("Navigating to SOP list");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SopListScreen(),
                    ),
                  );
                },
              ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Stats',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: stats.map((s) {
                    if (s.label == 'SOPs Created') {
                      return BlocBuilder<SopBloc, SopState>(
                        builder: (context, sopState) {
                          String dynamicSopCount = '0';
                          if (sopState is SopSuccess && sopState.history != null) {
                            dynamicSopCount = sopState.history!.length.toString();
                          }
                          return _StatTile(
                            item: _StatItem(
                              icon: s.icon,
                              iconColor: s.iconColor,
                              value: dynamicSopCount,
                              label: s.label,
                              onTap: s.onTap,
                            ),
                            isOffline: isOffline,
                          );
                        },
                      );
                    }
                    return _StatTile(
                      item: s, 
                      isOffline: isOffline,
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNoInternetSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "No Internet Connection",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _StatItem item;
  final bool isOffline;
  
  const _StatTile({
    required this.item,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isOffline ? 0.5 : 1.0,
      child: InkWell(
        onTap: isOffline ? () {
          print("QuickStatsGrid: Offline blocked");
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "No Internet Connection",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } : item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: item.iconColor, size: 24),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  item.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: const Color(0xFF3E4A3C),
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

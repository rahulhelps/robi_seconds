import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePackageCard extends StatelessWidget {
  const HomePackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF024D87).withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 32,
            right: 32,
            child: Icon(
              Icons.home,
              size: 150,
              color: const Color(0xFF024D87).withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF024D87).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DOMESTIC EXCELLENCE',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF024D87),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Home Package',
                  style: GoogleFonts.manrope(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Optimized for domestic markets and rapid career progression within your home region.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF3E4A3C),
                  ),
                ),
                const SizedBox(height: 32),
                const _FeatureItem(
                  icon: Icons.verified_user,
                  title: 'Professional CV',
                  subtitle: 'Industry-standard editorial design with custom layout.',
                ),
                const SizedBox(height: 24),
                const _FeatureItem(
                  icon: Icons.mail,
                  title: 'Cover Letter',
                  subtitle: 'A persuasive narrative tailored to your target sector.',
                ),
                const SizedBox(height: 24),
                const _FeatureItem(
                  icon: Icons.bolt,
                  title: 'Skills Optimization',
                  subtitle: 'Strategic keyword mapping for search visibility.',
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INVESTMENT',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: const Color(0xFF3E4A3C),
                          ),
                        ),
                        Text(
                          '\$149',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF191C1D),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 4,
                        shadowColor: const Color(0xFF024D87).withValues(alpha: 0.2),
                      ).copyWith(backgroundColor: WidgetStateProperty.all(Colors.transparent)),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF024D87), Color(0xFF28A745)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          child: Text(
                            'Select Package',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF024D87), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1D),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF3E4A3C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hero card showing icon, title and subtitle — mirrors the HTML <section> card.
class EmailRegHeroCard extends StatelessWidget {
  const EmailRegHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0x1A006E25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF024D87),
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Complete Your Profile',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF191C1D),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add your email address to sync your resumes\nacross all your premium devices.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6E7B6B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

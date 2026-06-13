import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PackagesHeroSection extends StatelessWidget {
  const PackagesHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE CAREER CURATOR',
          style: GoogleFonts.inter(
            color: const Color(0xFF024D87),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.12,
              color: const Color(0xFF191C1D),
            ),
            children: const [
              TextSpan(text: 'Tailored '),
              TextSpan(
                text: 'Career',
                style: TextStyle(color: Color(0xFF024D87)),
              ),
              TextSpan(text: '\nNarratives.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Elevate your professional trajectory with bespoke CV solutions. We don't just list experiences; we curate your success story.",
          style: GoogleFonts.inter(
            fontSize: 18,
            color: const Color(0xFF3E4A3C),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

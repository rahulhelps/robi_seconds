import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryHeroSection extends StatelessWidget {
  const GalleryHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEMPLATE GALLERY',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: const Color(0xFF024D87),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
              color: const Color(0xFF191C1D),
            ),
            children: const [
              TextSpan(text: 'Curate Your Professional\n'),
              TextSpan(
                text: 'Narrative.',
                style: TextStyle(color: Color(0xFF024D87)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Selected designs optimized for Applicant Tracking Systems (ATS) and curated for high-end corporate presence.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF3E4A3C),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

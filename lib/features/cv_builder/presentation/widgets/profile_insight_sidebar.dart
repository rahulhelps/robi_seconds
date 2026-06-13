import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInsightSidebar extends StatelessWidget {
  const ProfileInsightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFBDCAB9).withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profile Insight',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF191C1D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const _CircularProgressWidget(),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF3E4A3C),
                  ),
                  children: const [
                    TextSpan(text: 'A complete profile increases your chances of being noticed by top-tier recruiters by '),
                    TextSpan(
                      text: '40%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF024D87),
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFE1E3E4),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder for actual image: NetworkImage or Asset
              const ColoredBox(color: Colors.grey),
              // Gradient Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'PRO TIP',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use a high-resolution headshot for better engagement.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircularProgressWidget extends StatelessWidget {
  const _CircularProgressWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: CircularProgressIndicator(
              value: 0.15, // 15% complete
              strokeWidth: 8,
              backgroundColor: const Color(0xFFE1E3E4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF51B1E1)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '15%',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF191C1D),
                ),
              ),
              Text(
                'COMPLETE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: const Color(0xFF3E4A3C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

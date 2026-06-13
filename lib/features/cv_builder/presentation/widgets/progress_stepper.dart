import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepItem(step: 1, title: 'Personal Info', isActive: true),
          _StepDivider(),
          _StepItem(step: 2, title: 'Education', isActive: false),
          _StepDivider(),
          _StepItem(step: 3, title: 'Experience', isActive: false),
          _StepDivider(hiddenOnMobile: true),
          _StepItem(step: 4, title: 'Skills', isActive: false, hiddenOnMobile: true),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;
  final bool hiddenOnMobile;

  const _StepItem({
    required this.step,
    required this.title,
    this.isActive = false,
    this.hiddenOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hiddenOnMobile && MediaQuery.of(context).size.width < 768) {
      return const SizedBox.shrink();
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF28A745).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF024D87),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                step.toString(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF024D87),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ).copyWith(textBaseline: TextBaseline.alphabetic),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Opacity(
        opacity: 0.4,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFE1E3E4),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                step.toString(),
                style: GoogleFonts.inter(
                  color: const Color(0xFF3E4A3C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF3E4A3C),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  final bool hiddenOnMobile;

  const _StepDivider({this.hiddenOnMobile = false});

  @override
  Widget build(BuildContext context) {
    if (hiddenOnMobile && MediaQuery.of(context).size.width < 768) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 32,
      height: 2,
      color: const Color(0xFFE1E3E4),
    );
  }
}

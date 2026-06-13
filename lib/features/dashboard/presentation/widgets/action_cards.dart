import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcvpro/core/widgets/pressable_scale.dart';
import 'package:quickcvpro/features/cover_letter/presentation/screens/cover_letter_screen.dart';
import '../../../cv_builder/presentation/screens/template_gallery_screen.dart';

/// 2×2 grid of quick-action cards.
class ActionCards extends StatelessWidget {
  const ActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.add_circle_outline_rounded,
                title: 'Create New CV',
                subtitle: 'Build your professional CV',
                isPrimary: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TemplateGalleryScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.description_outlined,
                title: 'Cover Letter',
                subtitle: 'Generate cover letters',
                isPrimary: false,
                onTap: () =>  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CoverLetterScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Row 2
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.school_outlined,
                title: 'SOP',
                subtitle: 'Statement of purpose',
                isPrimary: false,
                onTap: () => Navigator.pushNamed(context, '/sop'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.mark_email_read_outlined,
                title: 'Professional Email',
                subtitle: 'Create professional emails',
                isPrimary: false,
                onTap: () => _showComingSoon(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Coming Soon',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF191C1D),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 148,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF024D87), Color(0xFF0369B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : const Color(0xFF024D87).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFF024D87), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF024D87).withValues(alpha: 0.25),
              blurRadius: isPrimary ? 24 : 16,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

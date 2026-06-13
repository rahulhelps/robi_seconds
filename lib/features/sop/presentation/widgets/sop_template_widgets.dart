import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/sop_template.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reusable SOP template gallery widgets.
// All widgets are extracted from the template screen for a clean build().
// ─────────────────────────────────────────────────────────────────────────────

/// Animated grid card for a single template.
class TemplateCard extends StatelessWidget {
  final SopTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 4),
              spreadRadius: isSelected ? 1 : 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail preview area
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TemplateThumbnail(templateId: template.id),
                  if (template.isPremium)
                    const Positioned(top: 8, right: 8, child: PremiumBadge()),
                  if (isSelected)
                    const Positioned(
                      bottom: 8,
                      right: 8,
                      child: SelectionCheckmark(),
                    ),
                ],
              ),
            ),
            // Template info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      template.name,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      template.description,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rich mini document preview — unique layout per template ID.
class TemplateThumbnail extends StatelessWidget {
  final String templateId;

  const TemplateThumbnail({super.key, required this.templateId});

  @override
  Widget build(BuildContext context) {
    return switch (templateId) {
      'classic_academic'        => const _HarvardThumb(),
      'modern_professional'     => const _ModernMinimalThumb(),
      'research_focused'        => const _ResearchThumb(),
      'career_change'           => const _CreativeThumb(),
      'engineering_tech'        => const _TechThumb(),
      'business_mba'            => const _ExecutiveThumb(),
      'medical_health'          => const _MedicalThumb(),
      'arts_humanities'         => const _ElegantThumb(),
      'international_student'   => const _InternationalThumb(),
      'scholarship_application' => const _ScholarshipThumb(),
      _                         => const _HarvardThumb(),
    };
  }
}

// ── Gold "PREMIUM" badge ──────────────────────────────────────────────────────

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 9),
          const SizedBox(width: 3),
          Text(
            'PREMIUM',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blue checkmark overlay for selected card ─────────────────────────────────

class SelectionCheckmark extends StatelessWidget {
  const SelectionCheckmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x40024D87),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
    );
  }
}

// ── Full-width gradient bottom button ────────────────────────────────────────

class UseTemplateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UseTemplateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onPressed,
                icon: const Icon(Icons.edit_document, color: Colors.white, size: 20),
                label: Text(
                  'Use This Template  →',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Individual template thumbnail implementations
// Each uses a unique mock-document layout with the template's real colors
// ═════════════════════════════════════════════════════════════════════════════

// ── Template 1: Classic Harvard ──────────────────────────────────────────────
class _HarvardThumb extends StatelessWidget {
  const _HarvardThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Navy header bar
          Container(
            height: 36,
            color: const Color(0xFF0D1B2A),
            child: Center(
              child: Container(
                width: 60, height: 2,
                color: const Color(0xFFD4A017),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Content lines
          const _MockLines(accentColor: Color(0xFFD4A017), centered: true),
        ],
      ),
    );
  }
}

// ── Template 2: Modern Minimal ────────────────────────────────────────────────
class _ModernMinimalThumb extends StatelessWidget {
  const _ModernMinimalThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Blue left bar
          Container(width: 4, color: const Color(0xFF024D87)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70, height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF024D87),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _MockLines(accentColor: Color(0xFF024D87), dotPrefix: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template 3: Research Scholar ──────────────────────────────────────────────
class _ResearchThumb extends StatelessWidget {
  const _ResearchThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title centered
          Center(
            child: Container(
              width: 80, height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(height: 1.5, color: const Color(0xFF1E3A8A)),
          const SizedBox(height: 2),
          Container(height: 0.5, color: const Color(0xFF1E3A8A)),
          const SizedBox(height: 6),
          // Abstract box
          Container(
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF5),
              border: Border.all(color: const Color(0xFFB0BFDB), width: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          const _MockLines(accentColor: Color(0xFF1E3A8A), numbered: true),
        ],
      ),
    );
  }
}

// ── Template 4: Creative Modern (Career Change) ───────────────────────────────
class _CreativeThumb extends StatelessWidget {
  const _CreativeThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Deep blue header with accent strip
        Container(
          height: 40,
          color: const Color(0xFF013A65),
          child: Column(
            children: [
              const Spacer(),
              Container(height: 3, color: const Color(0xFF51B1E1)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: const _MockLines(
              accentColor: Color(0xFF024D87),
              leftPill: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Template 5: Tech / Engineering ───────────────────────────────────────────
class _TechThumb extends StatelessWidget {
  const _TechThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          // Light grey header with teal left bar
          Container(
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Container(width: 4, color: const Color(0xFF10B981)),
                const SizedBox(width: 8),
                Container(
                  width: 50, height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const _MockLines(
                accentColor: Color(0xFF10B981),
                brackets: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template 6: Executive Professional (Business/MBA) ─────────────────────────
class _ExecutiveThumb extends StatelessWidget {
  const _ExecutiveThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Charcoal header
          Container(
            height: 40,
            color: const Color(0xFF2C2C2C),
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60, height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    3,
                    (_) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const _MockLines(
                accentColor: Color(0xFF2C2C2C),
                underline: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template 7: Elegant Classic (Arts) ───────────────────────────────────────
class _ElegantThumb extends StatelessWidget {
  const _ElegantThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Corner decorations (just lines)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 16, height: 1.5, color: const Color(0xFF78350F)),
              Container(width: 16, height: 1.5, color: const Color(0xFF78350F)),
            ],
          ),
          const SizedBox(height: 6),
          // Centered name
          Center(
            child: Container(
              width: 65, height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF78350F).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Container(width: 50, height: 1, color: const Color(0xFF78350F)),
          ),
          const SizedBox(height: 8),
          const Expanded(child: _MockLines(accentColor: Color(0xFF78350F))),
        ],
      ),
    );
  }
}

// ── Template 8: Medical Professional ─────────────────────────────────────────
class _MedicalThumb extends StatelessWidget {
  const _MedicalThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Green top bar
          Container(height: 4, color: const Color(0xFF0D9488)),
          // Light green header
          Container(
            height: 30,
            color: const Color(0xFFF0FDF4),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              children: [
                Container(
                  width: 55, height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1.5, color: const Color(0xFF0D9488)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const _MockLines(
                accentColor: Color(0xFF0D9488),
                pillHeader: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template 9: International / Global ───────────────────────────────────────
class _InternationalThumb extends StatelessWidget {
  const _InternationalThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Three-color flag bar
          SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(child: Container(color: const Color(0xFF0369A1))),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: const Color(0xFFDC2626))),
              ],
            ),
          ),
          // Sky header
          Container(
            height: 28,
            color: const Color(0xFFF0F9FF),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Container(
              width: 55, height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF0369A1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(height: 1, color: const Color(0xFF0369A1)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const _MockLines(
                accentColor: Color(0xFF0369A1),
                leftTick: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template 10: Premium Scholarship ─────────────────────────────────────────
class _ScholarshipThumb extends StatelessWidget {
  const _ScholarshipThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Gold top strip
          Container(height: 3, color: const Color(0xFFD4A017)),
          // Navy header
          Container(
            height: 38,
            color: const Color(0xFF0D1B2A),
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 55, height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40, height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
                // Emblem circle
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A017), width: 1.5),
                  ),
                ),
              ],
            ),
          ),
          // Gold bottom strip
          Container(height: 2, color: const Color(0xFFD4A017)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const _MockLines(
                accentColor: Color(0xFFD4A017),
                diamond: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _MockLines — configurable fake text line rows for thumbnails
// ═════════════════════════════════════════════════════════════════════════════

class _MockLines extends StatelessWidget {
  final Color accentColor;
  final bool centered;
  final bool dotPrefix;
  final bool numbered;
  final bool leftPill;
  final bool brackets;
  final bool underline;
  final bool pillHeader;
  final bool leftTick;
  final bool diamond;

  const _MockLines({
    required this.accentColor,
    this.centered = false,
    this.dotPrefix = false,
    this.numbered = false,
    this.leftPill = false,
    this.brackets = false,
    this.underline = false,
    this.pillHeader = false,
    this.leftTick = false,
    this.diamond = false,
  });

  @override
  Widget build(BuildContext context) {
    final sections = [
      (0.55, [0.9, 0.75]),
      (0.45, [0.85, 0.65]),
    ];

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          _sectionHeader(sections[i].$1, i),
          const SizedBox(height: 3),
          for (final lineW in sections[i].$2) ...[
            _line(lineW),
            const SizedBox(height: 2),
          ],
          const SizedBox(height: 5),
        ],
      ],
    );
  }

  Widget _sectionHeader(double width, int index) {
    if (pillHeader) {
      return Container(
        width: double.infinity,
        height: 8,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    return Row(
      children: [
        if (dotPrefix)
          Container(
            width: 4, height: 4,
            margin: const EdgeInsets.only(right: 3, top: 1),
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
        if (numbered)
          Text('${index + 1}.',
              style: TextStyle(fontSize: 6, color: accentColor, fontWeight: FontWeight.bold)),
        if (leftPill)
          Container(
            width: 3, height: 8,
            margin: const EdgeInsets.only(right: 3),
            color: accentColor,
          ),
        if (brackets)
          Text('[',
              style: TextStyle(fontSize: 6, color: accentColor, fontWeight: FontWeight.bold)),
        if (diamond)
          Text('◆ ',
              style: TextStyle(fontSize: 5, color: accentColor)),
        if (leftTick)
          Container(
            width: 2, height: 8,
            margin: const EdgeInsets.only(right: 3),
            color: accentColor,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80 * width,
              height: 7,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            if (underline) ...[
              const SizedBox(height: 1),
              Container(
                width: 80 * width,
                height: 0.75,
                color: accentColor,
              ),
            ],
          ],
        ),
        if (brackets)
          Text(']', style: TextStyle(fontSize: 6, color: accentColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _line(double width) => Container(
        width: double.infinity * width,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(1),
        ),
      );
}

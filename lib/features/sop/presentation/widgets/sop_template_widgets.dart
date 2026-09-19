import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/sop_template.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Reusable SOP template gallery widgets.
// Cute, Material 3 academic document previews with realistic A4 paper framing,
// university emblems, category tags, and responsive layouts.
// ─────────────────────────────────────────────────────────────────────────────

/// Animated grid card for a single SOP template.
class TemplateCard extends StatelessWidget {
  final SopTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const TemplateCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.onPreview,
  });

  Color get _accentColor {
    switch (template.id) {
      case 'classic_academic': return const Color(0xFF0D1B2A);
      case 'modern_professional': return const Color(0xFF024D87);
      case 'research_focused': return const Color(0xFF1E3A8A);
      case 'career_change': return const Color(0xFF4F46E5);
      case 'engineering_tech': return const Color(0xFF0F172A);
      case 'business_mba': return const Color(0xFF1C1C1E);
      case 'medical_health': return const Color(0xFF0D9488);
      case 'arts_humanities': return const Color(0xFF78350F);
      case 'international_student': return const Color(0xFF0369A1);
      case 'scholarship_application': return const Color(0xFF0B192C);
      default: return AppColors.primary;
    }
  }

  String get _categoryTag {
    switch (template.id) {
      case 'classic_academic': return 'IVY LEAGUE';
      case 'modern_professional': return 'ACADEMIC PRO';
      case 'research_focused': return 'RESEARCH LAB';
      case 'career_change': return 'CAREER PIVOT';
      case 'engineering_tech': return 'STEM & TECH';
      case 'business_mba': return 'MBA & MGMT';
      case 'medical_health': return 'HEALTHCARE';
      case 'arts_humanities': return 'HUMANITIES';
      case 'international_student': return 'GLOBAL STUDY';
      case 'scholarship_application': return 'SCHOLARSHIP';
      default: return 'ACADEMIC';
    }
  }

  IconData get _icon {
    switch (template.id) {
      case 'classic_academic': return Icons.school_rounded;
      case 'modern_professional': return Icons.history_edu_rounded;
      case 'research_focused': return Icons.science_rounded;
      case 'career_change': return Icons.sync_alt_rounded;
      case 'engineering_tech': return Icons.code_rounded;
      case 'business_mba': return Icons.insights_rounded;
      case 'medical_health': return Icons.medical_services_rounded;
      case 'arts_humanities': return Icons.auto_stories_rounded;
      case 'international_student': return Icons.public_rounded;
      case 'scholarship_application': return Icons.emoji_events_rounded;
      default: return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _accentColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.05),
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
            // ── Top: Realistic Mini A4 Academic Document Preview ───────────
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // A4 Paper Sheet
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: TemplateThumbnail(templateId: template.id),
                      ),
                    ),

                    // Quick Eye Preview Button
                    if (onPreview != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: onPreview,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.remove_red_eye_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                    // Premium Badge
                    if (template.isPremium)
                      const Positioned(top: 8, right: 8, child: PremiumBadge()),

                    // Selection Checkmark
                    if (isSelected)
                      Positioned(
                        bottom: 4,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _accentColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Bottom: Template Info ──────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_icon, size: 9, color: _accentColor),
                              const SizedBox(width: 3),
                              Text(
                                _categoryTag,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: _accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.name,
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      template.description,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        height: 1.25,
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

/// Sleek, compact list card for a single SOP template.
class TemplateListItem extends StatelessWidget {
  final SopTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const TemplateListItem({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.onPreview,
  });

  Color get _accentColor {
    switch (template.id) {
      case 'classic_academic': return const Color(0xFF0D1B2A);
      case 'modern_professional': return const Color(0xFF024D87);
      case 'research_focused': return const Color(0xFF1E3A8A);
      case 'career_change': return const Color(0xFF4F46E5);
      case 'engineering_tech': return const Color(0xFF0F172A);
      case 'business_mba': return const Color(0xFF1C1C1E);
      case 'medical_health': return const Color(0xFF0D9488);
      case 'arts_humanities': return const Color(0xFF78350F);
      case 'international_student': return const Color(0xFF0369A1);
      case 'scholarship_application': return const Color(0xFF0B192C);
      default: return AppColors.primary;
    }
  }

  String get _categoryTag {
    switch (template.id) {
      case 'classic_academic': return 'IVY LEAGUE';
      case 'modern_professional': return 'ACADEMIC PRO';
      case 'research_focused': return 'RESEARCH LAB';
      case 'career_change': return 'CAREER PIVOT';
      case 'engineering_tech': return 'STEM & TECH';
      case 'business_mba': return 'MBA & MGMT';
      case 'medical_health': return 'HEALTHCARE';
      case 'arts_humanities': return 'HUMANITIES';
      case 'international_student': return 'GLOBAL STUDY';
      case 'scholarship_application': return 'SCHOLARSHIP';
      default: return 'ACADEMIC';
    }
  }

  IconData get _icon {
    switch (template.id) {
      case 'classic_academic': return Icons.school_rounded;
      case 'modern_professional': return Icons.history_edu_rounded;
      case 'research_focused': return Icons.science_rounded;
      case 'career_change': return Icons.sync_alt_rounded;
      case 'engineering_tech': return Icons.code_rounded;
      case 'business_mba': return Icons.insights_rounded;
      case 'medical_health': return Icons.medical_services_rounded;
      case 'arts_humanities': return Icons.auto_stories_rounded;
      case 'international_student': return Icons.public_rounded;
      case 'scholarship_application': return Icons.emoji_events_rounded;
      default: return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _accentColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading: Themed emblem
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? _accentColor : _accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _icon,
                color: isSelected ? Colors.white : _accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Name, tag, description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          template.name,
                          style: GoogleFonts.manrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _categoryTag,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: _accentColor,
                          ),
                        ),
                      ),
                      if (template.isPremium) ...[
                        const SizedBox(width: 6),
                        const PremiumBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing: Eye Preview & Selection Ring
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onPreview != null)
                  GestureDetector(
                    onTap: onPreview,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? _accentColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _accentColor : const Color(0xFFCBD5E1),
                      width: isSelected ? 0 : 1.8,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 5,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 9),
          const SizedBox(width: 2.5),
          Text(
            'PRO',
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
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x40024D87),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
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
// Realistic academic document previews with university headers & seals
// ═════════════════════════════════════════════════════════════════════════════

// ── Template 1: Classic Harvard ──────────────────────────────────────────────
class _HarvardThumb extends StatelessWidget {
  const _HarvardThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ivy League Crimson / Navy header with gold crest
        Container(
          height: 32,
          color: const Color(0xFF0D1B2A),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.school_rounded, color: Color(0xFFD4A017), size: 14),
              const SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 32,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(height: 2, color: const Color(0xFFD4A017)),
        // Content lines
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF0D1B2A), centered: true),
          ),
        ),
      ],
    );
  }
}

// ── Template 2: Modern Minimal ────────────────────────────────────────────────
class _ModernMinimalThumb extends StatelessWidget {
  const _ModernMinimalThumb();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Deep blue left margin spine
        Container(width: 5, color: const Color(0xFF024D87)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF024D87),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF024D87).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_edu_rounded, size: 9, color: Color(0xFF024D87)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Expanded(
                  child: _MockLines(accentColor: Color(0xFF024D87), dotPrefix: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Template 3: Research Scholar ──────────────────────────────────────────────
class _ResearchThumb extends StatelessWidget {
  const _ResearchThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 28,
          color: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.science_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 5),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Abstract Callout Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(width: 3, height: 10, color: const Color(0xFF1E3A8A)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 40, height: 3, color: const Color(0xFF1E3A8A)),
                            const SizedBox(height: 2),
                            Container(width: 60, height: 2, color: const Color(0xFF93C5FD)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Expanded(
                  child: _MockLines(accentColor: Color(0xFF1E3A8A), numbered: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Template 4: Career Change (Creative Modern) ───────────────────────────────
class _CreativeThumb extends StatelessWidget {
  const _CreativeThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 5),
              Container(
                width: 52,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF4F46E5), leftPill: true),
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
    return Column(
      children: [
        // Dark terminal header
        Container(
          height: 26,
          color: const Color(0xFF0F172A),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Row(
            children: [
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
              const SizedBox(width: 3),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Icon(Icons.code_rounded, color: Color(0xFF10B981), size: 11),
              const SizedBox(width: 4),
              Container(
                width: 35,
                height: 3.5,
                decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(1.5)),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF10B981), brackets: true),
          ),
        ),
      ],
    );
  }
}

// ── Template 6: Executive Professional (Business/MBA) ─────────────────────────
class _ExecutiveThumb extends StatelessWidget {
  const _ExecutiveThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Charcoal header with metric chips
        Container(
          height: 32,
          color: const Color(0xFF1C1C1E),
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded, color: Color(0xFFF59E0B), size: 11),
                  const SizedBox(width: 4),
                  Container(width: 45, height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1))),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF1C1C1E), underline: true),
          ),
        ),
      ],
    );
  }
}

// ── Template 7: Elegant Classic (Arts) ───────────────────────────────────────
class _ElegantThumb extends StatelessWidget {
  const _ElegantThumb();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 14, height: 1.5, color: const Color(0xFF78350F)),
              const Icon(Icons.auto_stories_rounded, color: Color(0xFF78350F), size: 12),
              Container(width: 14, height: 1.5, color: const Color(0xFF78350F)),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            width: 55,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF78350F),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(width: 35, height: 1, color: const Color(0xFF78350F).withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          const Expanded(child: _MockLines(accentColor: Color(0xFF78350F), centered: true)),
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
    return Column(
      children: [
        Container(
          height: 28,
          color: const Color(0xFF0D9488),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.medical_services_rounded, color: Colors.white, size: 12),
              const SizedBox(width: 5),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF0D9488), pillHeader: true),
          ),
        ),
      ],
    );
  }
}

// ── Template 9: International / Global ───────────────────────────────────────
class _InternationalThumb extends StatelessWidget {
  const _InternationalThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tri-color global ribbon
        SizedBox(
          height: 4,
          child: Row(
            children: [
              Expanded(child: Container(color: const Color(0xFF0369A1))),
              Expanded(child: Container(color: const Color(0xFFF59E0B))),
              Expanded(child: Container(color: const Color(0xFFDC2626))),
            ],
          ),
        ),
        Container(
          height: 25,
          color: const Color(0xFFF0F9FF),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.public_rounded, color: Color(0xFF0369A1), size: 12),
              const SizedBox(width: 5),
              Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFF0369A1), borderRadius: BorderRadius.circular(1.5)),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF0369A1), leftTick: true),
          ),
        ),
      ],
    );
  }
}

// ── Template 10: Premium Scholarship ─────────────────────────────────────────
class _ScholarshipThumb extends StatelessWidget {
  const _ScholarshipThumb();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 32,
          color: const Color(0xFF0B192C),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 14),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1.5)),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 28,
                    height: 2.5,
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(1)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(height: 2, color: const Color(0xFFF59E0B)),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _MockLines(accentColor: Color(0xFF0B192C), diamond: true),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _MockLines — proportional fake text line rows with clean fraction geometry
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
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _sectionHeader(0.55, 0),
        const SizedBox(height: 2.5),
        _line(0.95),
        const SizedBox(height: 2),
        _line(0.80),
        const SizedBox(height: 2),
        _line(0.65),
        const SizedBox(height: 4.5),
        _sectionHeader(0.45, 1),
        const SizedBox(height: 2.5),
        _line(0.90),
        const SizedBox(height: 2),
        _line(0.75),
        const SizedBox(height: 2),
        _line(0.60),
        const SizedBox(height: 4.5),
        _sectionHeader(0.40, 2),
        const SizedBox(height: 2.5),
        _line(0.85),
        const SizedBox(height: 2),
        _line(0.50),
      ],
    );
  }

  Widget _line(double fraction) {
    return FractionallySizedBox(
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      widthFactor: fraction,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  Widget _sectionHeader(double widthFactor, int index) {
    if (pillHeader) {
      return Container(
        width: double.infinity,
        height: 7,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (dotPrefix)
          Container(
            width: 3.5, height: 3.5,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
        if (numbered)
          Text(
            '${index + 1}.',
            style: TextStyle(fontSize: 6, color: accentColor, fontWeight: FontWeight.bold),
          ),
        if (leftPill)
          Container(
            width: 2.5, height: 7,
            margin: const EdgeInsets.only(right: 3),
            color: accentColor,
          ),
        if (brackets)
          Text('[', style: TextStyle(fontSize: 6, color: accentColor, fontWeight: FontWeight.bold)),
        if (diamond)
          Text('◆ ', style: TextStyle(fontSize: 5, color: accentColor)),
        if (leftTick)
          Container(
            width: 2, height: 7,
            margin: const EdgeInsets.only(right: 3),
            color: accentColor,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50 * widthFactor,
              height: 5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            if (underline) ...[
              const SizedBox(height: 1),
              Container(
                width: 50 * widthFactor,
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
}

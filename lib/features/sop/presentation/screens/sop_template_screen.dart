import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/sop_templates.dart';
import '../../domain/sop_template.dart';
import '../widgets/sop_template_widgets.dart';
import 'sop_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SopTemplateScreen — professional template gallery with rich mini-previews,
// premium badges, animated selection, and gradient action bar.
// No BLoC/API changes — all selection logic preserved exactly.
// ─────────────────────────────────────────────────────────────────────────────

class SopTemplateScreen extends StatefulWidget {
  const SopTemplateScreen({super.key});

  @override
  State<SopTemplateScreen> createState() => _SopTemplateScreenState();
}

class _SopTemplateScreenState extends State<SopTemplateScreen> {
  String _selectedTemplateId = sopTemplates.first.id;
  bool _isListView = true;

  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Ivy League & Academic',
    'STEM & Tech',
    'MBA & Business',
    'Medical & Arts',
    'Scholarship & Global',
  ];

  List<SopTemplate> get _filteredTemplates {
    if (_selectedCategory == 'All') return sopTemplates;
    switch (_selectedCategory) {
      case 'Ivy League & Academic':
        return sopTemplates.where((t) =>
            t.id == 'classic_academic' ||
            t.id == 'modern_professional' ||
            t.id == 'research_focused').toList();
      case 'STEM & Tech':
        return sopTemplates.where((t) => t.id == 'engineering_tech').toList();
      case 'MBA & Business':
        return sopTemplates.where((t) => t.id == 'business_mba').toList();
      case 'Medical & Arts':
        return sopTemplates.where((t) =>
            t.id == 'medical_health' || t.id == 'arts_humanities').toList();
      case 'Scholarship & Global':
        return sopTemplates.where((t) =>
            t.id == 'scholarship_application' ||
            t.id == 'international_student' ||
            t.id == 'career_change').toList();
      default:
        return sopTemplates;
    }
  }

  /// Validates premium access before allowing selection.
  Future<void> _onTemplateTapped(SopTemplate template) async {
    if (template.isPremium) {
      final isPremiumActive = await SecureStorageHelper.getSubscriptionStatus();
      if (!isPremiumActive) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Premium feature. Upgrade to unlock this template.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              ),
            );
        }
        return;
      }
    }
    setState(() => _selectedTemplateId = template.id);
  }

  void _showSopPreviewModal(SopTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (previewCtx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191C1D),
                            ),
                          ),
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
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(previewCtx),
                    ),
                  ],
                ),
              ),

              // A4 Document Preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Banner
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'STATEMENT OF PURPOSE',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(height: 2, width: 40, color: AppColors.primary),
                              const SizedBox(height: 12),
                              Text(
                                'Applicant: [Your Name] • Program: Master of Science\nTarget Institution: [Selected University]',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Academic Background
                        _buildPreviewSection(
                          '1. Academic Foundation & Motivation',
                          'From my early undergraduate education, I have been captivated by fundamental challenges in this discipline. Through rigorous coursework, hands-on lab projects, and seminars, I built a strong analytical mindset, graduating with distinction.',
                        ),

                        // Section 2: Research & Experience
                        _buildPreviewSection(
                          '2. Research & Practical Exposure',
                          'In my academic and professional journey, I led technical explorations focusing on performance optimization, collaborative development, and critical thinking. These experiences taught me to formulate clear research questions and implement scalable solutions.',
                        ),

                        // Section 3: Why This Institution
                        _buildPreviewSection(
                          '3. Why This Program & Institution',
                          'Your esteemed university offers the ideal combination of distinguished faculty mentorship, cutting-edge facilities, and interdisciplinary inquiry. The program curriculum aligns directly with my research roadmap and career aspirations.',
                        ),

                        // Section 4: Future Trajectory
                        _buildPreviewSection(
                          '4. Career Goals & Vision',
                          'Following graduation, I intend to leverage this advanced training to pioneer solutions addressing high-impact industry and academic challenges. I look forward to contributing actively to your scholarly community.',
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'Respectfully submitted,\n[Your Name]',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(previewCtx);
                        setState(() => _selectedTemplateId = template.id);
                        _proceedToForm();
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        'Select This Template & Continue',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildPreviewSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to the SOP form with the selected template.
  void _proceedToForm() {
    final selected = sopTemplates.firstWhere((t) => t.id == _selectedTemplateId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SopScreen(
          templateId: selected.id,
          templateName: selected.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedTemplates = _filteredTemplates;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                // ── Gradient header ──────────────────────────────────────────
                _TemplateGalleryHeader(selectedCount: sopTemplates.length),

                // ── Category Filter Bar ──────────────────────────────────────
                Container(
                  height: 44,
                  margin: const EdgeInsets.only(top: 10, bottom: 2),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Count & View Mode Switcher ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  child: Row(
                    children: [
                      Text(
                        '${displayedTemplates.length} Templates',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ViewToggleBtn(
                              icon: Icons.view_list_rounded,
                              isSelected: _isListView,
                              tooltip: 'List View',
                              onTap: () => setState(() => _isListView = true),
                            ),
                            _ViewToggleBtn(
                              icon: Icons.grid_view_rounded,
                              isSelected: !_isListView,
                              tooltip: 'Grid View',
                              onTap: () => setState(() => _isListView = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Template List or Grid ────────────────────────────────────
                Expanded(
                  child: _isListView
                      ? ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          itemCount: displayedTemplates.length,
                          itemBuilder: (context, index) {
                            final template = displayedTemplates[index];
                            return TemplateListItem(
                              template: template,
                              isSelected: template.id == _selectedTemplateId,
                              onTap: () => _onTemplateTapped(template),
                              onPreview: () => _showSopPreviewModal(template),
                            );
                          },
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 2;
                            if (constraints.maxWidth >= 1400) {
                              crossAxisCount = 5;
                            } else if (constraints.maxWidth >= 1050) {
                              crossAxisCount = 4;
                            } else if (constraints.maxWidth >= 700) {
                              crossAxisCount = 3;
                            } else {
                              crossAxisCount = 2;
                            }

                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1360),
                                child: GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 0.72,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                                  itemCount: displayedTemplates.length,
                                  itemBuilder: (context, index) {
                                    final template = displayedTemplates[index];
                                    return TemplateCard(
                                      template: template,
                                      isSelected: template.id == _selectedTemplateId,
                                      onTap: () => _onTemplateTapped(template),
                                      onPreview: () => _showSopPreviewModal(template),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ── Bottom action button ─────────────────────────────────────
                UseTemplateButton(onPressed: _proceedToForm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TemplateGalleryHeader — gradient app bar with back button + subtitle
// ─────────────────────────────────────────────────────────────────────────────

class _TemplateGalleryHeader extends StatelessWidget {
  final int selectedCount;

  const _TemplateGalleryHeader({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(4, topPadding + 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              // Template count chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$selectedCount Templates',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Style',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Select a professional template for your SOP',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final String tooltip;
  final VoidCallback onTap;

  const _ViewToggleBtn({
    required this.icon,
    required this.isSelected,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.primary : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

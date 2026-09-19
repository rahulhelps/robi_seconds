import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/email_templates.dart';
import '../../domain/email_model.dart';
import '../bloc/email_bloc.dart';
import 'email_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/email_datasource.dart';
import '../../data/email_repository_impl.dart';
import '../../data/email_pdf_generator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmailTemplateScreen — professional template gallery for selecting email style.
// Follows EXACT same structure as SopTemplateScreen.
// ─────────────────────────────────────────────────────────────────────────────

class EmailTemplateScreen extends StatefulWidget {
  const EmailTemplateScreen({super.key});

  @override
  State<EmailTemplateScreen> createState() => _EmailTemplateScreenState();
}

class _EmailTemplateScreenState extends State<EmailTemplateScreen> {
  String _selectedTemplateId = emailTemplates.first.id;
  bool _isListView = true;

  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Corporate & Minimal',
    'Executive & Consulting',
    'Tech & Startup',
    'Creative & Media',
    'Healthcare & Finance',
  ];

  List<EmailTemplate> get _filteredTemplates {
    if (_selectedCategory == 'All') return emailTemplates;
    switch (_selectedCategory) {
      case 'Corporate & Minimal':
        return emailTemplates.where((t) =>
            t.id == 'corporate_formal' || t.id == 'modern_minimal').toList();
      case 'Executive & Consulting':
        return emailTemplates.where((t) =>
            t.id == 'executive' || t.id == 'consulting_firm').toList();
      case 'Tech & Startup':
        return emailTemplates.where((t) =>
            t.id == 'tech_industry' || t.id == 'startup_friendly').toList();
      case 'Creative & Media':
        return emailTemplates.where((t) => t.id == 'creative_professional').toList();
      case 'Healthcare & Finance':
        return emailTemplates.where((t) =>
            t.id == 'healthcare_medical' ||
            t.id == 'finance_banking' ||
            t.id == 'academic_research').toList();
      default:
        return emailTemplates;
    }
  }

  /// Validates premium access before allowing selection.
  Future<void> _onTemplateTapped(EmailTemplate template) async {
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

  void _showEmailPreviewModal(EmailTemplate template) {
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
                      child: const Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20),
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

              // Email Client Preview Window
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Client Meta Bar
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetaRow('Subject:', 'Application for [Position] - [Your Full Name]'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildMetaRow('To:', 'Hiring Team <recruitment@company.com>'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildMetaRow('From:', '[Your Name] <your.email@example.com>'),
                            ],
                          ),
                        ),

                        // Formatted Body
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dear Hiring Manager,',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'I am writing to express my strong interest in joining your esteemed organization. With proven experience in delivering impactful solutions and working collaboratively across cross-functional teams, I am confident in my ability to add immediate value.',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Key highlights I bring to this opportunity:\n• Demonstrated success in accelerating project milestones and optimizing workflows.\n• Strong problem-solving abilities paired with transparent, data-driven communication.\n• Proactive mindset and commitment to continuous learning and professional standards.',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'I would welcome the opportunity to discuss how my qualifications align with your current objectives. I am available for a conversation at your earliest convenience.',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Thank you for your time and consideration.',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155)),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.only(top: 10),
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sincerely,',
                                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '[Your Name]',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      '[Your Professional Title] | [Phone Number]',
                                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                        'Select This Template & Compose',
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

  Widget _buildMetaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  /// Navigates to the email form with the selected template.
  void _proceedToForm() {
    final selected = emailTemplates.firstWhere((t) => t.id == _selectedTemplateId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => EmailBloc(
            EmailRepositoryImpl(EmailDatasource()),
            EmailPdfGenerator(),
          )..add(const EmailHistoryRequested()),
          child: EmailScreen(
            templateId: selected.id,
            templateName: selected.name,
          ),
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
                _EmailTemplateGalleryHeader(selectedCount: emailTemplates.length),

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
                            return _EmailTemplateListItem(
                              template: template,
                              isSelected: template.id == _selectedTemplateId,
                              onTap: () => _onTemplateTapped(template),
                              onPreview: () => _showEmailPreviewModal(template),
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
                                    return _EmailTemplateCard(
                                      template: template,
                                      isSelected: template.id == _selectedTemplateId,
                                      onTap: () => _onTemplateTapped(template),
                                      onPreview: () => _showEmailPreviewModal(template),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ── Bottom action button ─────────────────────────────────────
                _UseTemplateButton(onPressed: _proceedToForm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmailTemplateGalleryHeader — EXACT same style as SopTemplateScreen header
// ─────────────────────────────────────────────────────────────────────────────

class _EmailTemplateGalleryHeader extends StatelessWidget {
  final int selectedCount;

  const _EmailTemplateGalleryHeader({required this.selectedCount});

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
                  'Select a professional template for your email',
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

// ─────────────────────────────────────────────────────────────────────────────
// _EmailTemplateListItem — sleek, compact list card for email template
// ─────────────────────────────────────────────────────────────────────────────

class _EmailTemplateListItem extends StatelessWidget {
  final EmailTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const _EmailTemplateListItem({
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.onPreview,
  });

  Color get _accentColor {
    switch (template.id) {
      case 'corporate_formal': return const Color(0xFF0D1B2A);
      case 'modern_minimal': return const Color(0xFF2563EB);
      case 'executive': return const Color(0xFF1C1C1E);
      case 'creative_professional': return const Color(0xFF7C3AED);
      case 'tech_industry': return const Color(0xFF10B981);
      case 'academic_research': return const Color(0xFF1E3A8A);
      case 'startup_friendly': return const Color(0xFFF59E0B);
      case 'consulting_firm': return const Color(0xFF374151);
      case 'healthcare_medical': return const Color(0xFF0D9488);
      case 'finance_banking': return const Color(0xFF92400E);
      default: return AppColors.primary;
    }
  }

  IconData get _templateIcon {
    switch (template.id) {
      case 'corporate_formal': return Icons.business_center_outlined;
      case 'modern_minimal': return Icons.minimize_rounded;
      case 'executive': return Icons.workspace_premium_outlined;
      case 'creative_professional': return Icons.palette_outlined;
      case 'tech_industry': return Icons.code_rounded;
      case 'academic_research': return Icons.school_outlined;
      case 'startup_friendly': return Icons.rocket_launch_outlined;
      case 'consulting_firm': return Icons.analytics_outlined;
      case 'healthcare_medical': return Icons.local_hospital_outlined;
      case 'finance_banking': return Icons.account_balance_outlined;
      default: return Icons.email_outlined;
    }
  }

  String get _categoryTag {
    switch (template.id) {
      case 'corporate_formal': return 'CORPORATE';
      case 'modern_minimal': return 'MINIMAL';
      case 'executive': return 'EXECUTIVE';
      case 'creative_professional': return 'CREATIVE';
      case 'tech_industry': return 'TECH & DEV';
      case 'academic_research': return 'ACADEMIA';
      case 'startup_friendly': return 'STARTUP';
      case 'consulting_firm': return 'CONSULTING';
      case 'healthcare_medical': return 'HEALTHCARE';
      case 'finance_banking': return 'FINANCE';
      default: return 'BUSINESS';
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
            // Leading: Themed email emblem
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? _accentColor : _accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _templateIcon,
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
                        const _EmailPremiumBadge(),
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

// ─────────────────────────────────────────────────────────────────────────────
// _EmailTemplateCard — visual preview card for each template
// ─────────────────────────────────────────────────────────────────────────────

class _EmailTemplateCard extends StatelessWidget {
  final EmailTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const _EmailTemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.onPreview,
  });

  // Template color mapping
  Color get _accentColor {
    switch (template.id) {
      case 'corporate_formal': return const Color(0xFF0D1B2A);
      case 'modern_minimal': return const Color(0xFF2563EB);
      case 'executive': return const Color(0xFF1C1C1E);
      case 'creative_professional': return const Color(0xFF7C3AED);
      case 'tech_industry': return const Color(0xFF10B981);
      case 'academic_research': return const Color(0xFF1E3A8A);
      case 'startup_friendly': return const Color(0xFFF59E0B);
      case 'consulting_firm': return const Color(0xFF374151);
      case 'healthcare_medical': return const Color(0xFF0D9488);
      case 'finance_banking': return const Color(0xFF92400E);
      default: return AppColors.primary;
    }
  }

  IconData get _templateIcon {
    switch (template.id) {
      case 'corporate_formal': return Icons.business_center_outlined;
      case 'modern_minimal': return Icons.minimize_rounded;
      case 'executive': return Icons.workspace_premium_outlined;
      case 'creative_professional': return Icons.palette_outlined;
      case 'tech_industry': return Icons.code_rounded;
      case 'academic_research': return Icons.school_outlined;
      case 'startup_friendly': return Icons.rocket_launch_outlined;
      case 'consulting_firm': return Icons.analytics_outlined;
      case 'healthcare_medical': return Icons.local_hospital_outlined;
      case 'finance_banking': return Icons.account_balance_outlined;
      default: return Icons.email_outlined;
    }
  }

  String get _categoryTag {
    switch (template.id) {
      case 'corporate_formal': return 'CORPORATE';
      case 'modern_minimal': return 'MINIMAL';
      case 'executive': return 'EXECUTIVE';
      case 'creative_professional': return 'CREATIVE';
      case 'tech_industry': return 'TECH & DEV';
      case 'academic_research': return 'ACADEMIA';
      case 'startup_friendly': return 'STARTUP';
      case 'consulting_firm': return 'CONSULTING';
      case 'healthcare_medical': return 'HEALTHCARE';
      case 'finance_banking': return 'FINANCE';
      default: return 'BUSINESS';
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
            // ── Top: Realistic Mini Email Client Preview ──────────────────
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Email Sheet
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Window Chrome bar with 3 dots
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                                  const SizedBox(width: 3),
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                                  const SizedBox(width: 3),
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const Spacer(),
                                  Icon(_templateIcon, size: 10, color: _accentColor),
                                ],
                              ),
                            ),

                            // Mini Email Header Banner
                            Container(
                              height: 22,
                              color: _accentColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _categoryTag,
                                      style: GoogleFonts.inter(
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Mini Email Body with structured layout
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Salutation
                                    Container(width: 35, height: 3.5, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(1.5))),
                                    const SizedBox(height: 5),

                                    // Paragraph 1
                                    Container(width: double.infinity, height: 3, decoration: BoxDecoration(color: const Color(0xFF94A3B8), borderRadius: BorderRadius.circular(1.5))),
                                    const SizedBox(height: 2.5),
                                    Container(width: 90, height: 3, decoration: BoxDecoration(color: const Color(0xFF94A3B8), borderRadius: BorderRadius.circular(1.5))),
                                    const SizedBox(height: 5),

                                    // Bullet points
                                    Row(
                                      children: [
                                        Container(width: 3, height: 3, decoration: BoxDecoration(color: _accentColor, shape: BoxShape.circle)),
                                        const SizedBox(width: 3),
                                        Container(width: 70, height: 2.5, decoration: BoxDecoration(color: const Color(0xFF64748B), borderRadius: BorderRadius.circular(1))),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(width: 3, height: 3, decoration: BoxDecoration(color: _accentColor, shape: BoxShape.circle)),
                                        const SizedBox(width: 3),
                                        Container(width: 60, height: 2.5, decoration: BoxDecoration(color: const Color(0xFF64748B), borderRadius: BorderRadius.circular(1))),
                                      ],
                                    ),
                                    const Spacer(),

                                    // Signature
                                    Row(
                                      children: [
                                        Container(width: 25, height: 2.5, decoration: BoxDecoration(color: const Color(0xFF94A3B8), borderRadius: BorderRadius.circular(1))),
                                        const SizedBox(width: 4),
                                        Container(width: 35, height: 3, decoration: BoxDecoration(color: _accentColor, borderRadius: BorderRadius.circular(1.5))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Eye preview button (Top Left)
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
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                            child: const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppColors.primary),
                          ),
                        ),
                      ),

                    // Premium PRO badge (Top Right)
                    if (template.isPremium)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: _EmailPremiumBadge(),
                      ),

                    // Selection Checkmark (Bottom Right)
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
                          child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Bottom: Template Info ─────────────────────────────────────
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
                          child: Text(
                            _categoryTag,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: _accentColor,
                            ),
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
                        color: const Color(0xFF191C1D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      template.description,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: const Color(0xFF64748B),
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

// ─────────────────────────────────────────────────────────────────────────────
// _UseTemplateButton — fixed bottom gradient button
// ─────────────────────────────────────────────────────────────────────────────

class _UseTemplateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _UseTemplateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
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
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onPressed,
              icon: const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 20),
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
    );
  }
}

class _EmailPremiumBadge extends StatelessWidget {
  const _EmailPremiumBadge();

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

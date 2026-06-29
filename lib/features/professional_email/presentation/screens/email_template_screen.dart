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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Gradient header ──────────────────────────────────────────
            _EmailTemplateGalleryHeader(selectedCount: emailTemplates.length),

            // ── Template grid ────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: emailTemplates.length,
                itemBuilder: (context, index) {
                  final template = emailTemplates[index];
                  return _EmailTemplateCard(
                    template: template,
                    isSelected: template.id == _selectedTemplateId,
                    onTap: () => _onTemplateTapped(template),
                  );
                },
              ),
            ),

            // ── Bottom action button ─────────────────────────────────────
            _UseTemplateButton(onPressed: _proceedToForm),
          ],
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
// _EmailTemplateCard — visual preview card for each template
// ─────────────────────────────────────────────────────────────────────────────

class _EmailTemplateCard extends StatelessWidget {
  final EmailTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmailTemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
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

  Color get _bgColor {
    switch (template.id) {
      case 'modern_minimal': return Colors.white;
      case 'tech_industry': return const Color(0xFFF9FAFB);
      case 'academic_research': return Colors.white;
      case 'startup_friendly': return const Color(0xFFFFFBF0);
      case 'creative_professional': return const Color(0xFFFAFAFF);
      case 'finance_banking': return const Color(0xFFFFFBF5);
      case 'healthcare_medical': return Colors.white;
      default: return Colors.white;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accentColor : const Color(0xFFE1E3E4),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _accentColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Color header preview ─────────────────────────────────────
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Stack(
                children: [
                  // Mini email preview lines
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 6, width: 80, color: Colors.white.withValues(alpha: 0.7), margin: const EdgeInsets.only(bottom: 5)),
                        Container(height: 4, width: 60, color: Colors.white.withValues(alpha: 0.4), margin: const EdgeInsets.only(bottom: 4)),
                        Container(height: 4, width: 70, color: Colors.white.withValues(alpha: 0.4), margin: const EdgeInsets.only(bottom: 4)),
                        Container(height: 4, width: 50, color: Colors.white.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                  // Icon
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Icon(_templateIcon, color: Colors.white.withValues(alpha: 0.6), size: 22),
                  ),
                  // Premium lock
                  if (template.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Selection check
                  if (isSelected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _accentColor, width: 2),
                        ),
                        child: Icon(Icons.check_rounded, size: 14, color: _accentColor),
                      ),
                    ),
                ],
              ),
            ),

            // ── Template info ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF191C1D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        template.description,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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

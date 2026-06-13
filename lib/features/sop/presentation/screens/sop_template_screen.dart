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
            _TemplateGalleryHeader(selectedCount: sopTemplates.length),

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
                itemCount: sopTemplates.length,
                itemBuilder: (context, index) {
                  final template = sopTemplates[index];
                  return TemplateCard(
                    template: template,
                    isSelected: template.id == _selectedTemplateId,
                    onTap: () => _onTemplateTapped(template),
                  );
                },
              ),
            ),

            // ── Bottom action button ─────────────────────────────────────
            UseTemplateButton(onPressed: _proceedToForm),
          ],
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

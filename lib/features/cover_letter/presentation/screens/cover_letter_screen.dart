import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/cover_letter_repository.dart';
import '../../domain/cover_letter_model.dart';
import '../bloc/cover_letter_bloc.dart';
import 'cover_letter_output_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/custom_gradient_header.dart';

/// Cover letter editor screen.
///
/// - Opens with default template pre-loaded.
/// - AppBar trailing icon opens template selector bottom sheet.
/// - Three editable sections: header, body, footer.
/// - FAB → POST /cover-letters → navigate to output screen.
class CoverLetterScreen extends StatelessWidget {
  const CoverLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoverLetterBloc(context.read<CoverLetterRepository>())..add(const LoadTemplates()),
      child: const _CoverLetterView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _CoverLetterView extends StatefulWidget {
  const _CoverLetterView();

  @override
  State<_CoverLetterView> createState() => _CoverLetterViewState();
}

class _CoverLetterViewState extends State<_CoverLetterView> {
  late final TextEditingController _headerCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _footerCtrl;

  @override
  void initState() {
    super.initState();
    // Will be populated dynamically when templates are loaded
    _headerCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _footerCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  // ── Template switch ────────────────────────────────────────────────────────

  void _syncControllersFromState(CoverLetterState state) {
    if (_headerCtrl.text != state.model.header) {
      _headerCtrl.text = state.model.header;
    }
    if (_bodyCtrl.text != state.model.body) {
      _bodyCtrl.text = state.model.body;
    }
    if (_footerCtrl.text != state.model.footer) {
      _footerCtrl.text = state.model.footer;
    }
  }

  void _openTemplateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: context.read<CoverLetterBloc>(),
          child: _TemplateSheet(
            onSelected: (id, index) {
              context
                  .read<CoverLetterBloc>()
                  .add(SelectTemplate(id, index));
              Navigator.pop(sheetCtx);
            },
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoverLetterBloc, CoverLetterState>(
      listener: (context, state) {
        // Sync text controllers when template changes
        if (state is CoverLetterInitial) {
          _syncControllersFromState(state);
        }
        // if (state is CoverLetterError) {
        //   ScaffoldMessenger.of(context)
        //     ..hideCurrentSnackBar()
        //     ..showSnackBar(
        //       SnackBar(
        //         content: Row(
        //           children: [
        //             const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        //             const SizedBox(width: 10),
        //             Expanded(
        //               child: Text(state.message, style: GoogleFonts.inter(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
        //             ),
        //           ],
        //         ),
        //         backgroundColor: const Color(0xFFBA1A1A),
        //         behavior: SnackBarBehavior.floating,
        //         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //       ),
        //     );
        // }
        if (state is CoverLetterSuccess) {
          if (kDebugMode) {
            print("Cover Letter created → refreshing profile");
          }
          context.read<ProfileBloc>().add(const FetchProfile(forceNetwork: true));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CoverLetterOutputScreen(saved: state.saved),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is CoverLetterLoading;

        return BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            final isOffline = connectivityState is ConnectivityOffline;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                body: Column(
                  children: [
                    CustomGradientHeader(
                      title: 'Cover Letter',
                      subtitle: 'Fill in your details below to draft your Cover Letter',
                      badgeText: state.model.title.isNotEmpty ? state.model.title : 'Template',
                      onBackPressed: () => Navigator.pop(context),
                    ),
                    AnimatedInternetBanner(
                      isOffline: isOffline,
                      onRetry: () => context.read<CoverLetterBloc>().add(const LoadTemplates()),
                    ),
                    Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template badge
                _TemplateBadge(
                  templateName: state.model.title,
                  onTap: isSubmitting || isOffline ? () {} : () => _openTemplateSheet(context),
                ),
                const SizedBox(height: 24),

                // Header section
                _SectionLabel(icon: Icons.person_outline_rounded, label: 'Header', hint: 'Name, address, date…'),
                const SizedBox(height: 8),
                _EditorField(
                  controller: _headerCtrl,
                  minLines: 3,
                  onChanged: (v) => context.read<CoverLetterBloc>().add(UpdateCoverLetterField('header', v)),
                ),
                const SizedBox(height: 20),

                // Body section
                _SectionLabel(icon: Icons.article_outlined, label: 'Body', hint: 'Main letter content…'),
                const SizedBox(height: 8),
                _EditorField(
                  controller: _bodyCtrl,
                  minLines: 10,
                  onChanged: (v) => context.read<CoverLetterBloc>().add(UpdateCoverLetterField('body', v)),
                ),
                const SizedBox(height: 20),

                            // Footer section
                            _SectionLabel(icon: Icons.border_bottom_rounded, label: 'Footer', hint: 'Sign-off, name, links…'),
                            const SizedBox(height: 8),
                            _EditorField(
                              controller: _footerCtrl,
                              minLines: 2,
                              onChanged: (v) => context.read<CoverLetterBloc>().add(UpdateCoverLetterField('footer', v)),
                            ),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF024D87),
                foregroundColor: Colors.white,
                onPressed: isOffline
                    ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Internet Connection')))
                    : isSubmitting ? null : () => context.read<CoverLetterBloc>().add(const CreateCoverLetter()),
                icon: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isSubmitting ? 'Saving…' : 'Save & Preview',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TemplateBadge extends StatelessWidget {
  final String templateName;
  final VoidCallback onTap;
  const _TemplateBadge({required this.templateName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA3CEB0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_motion_rounded,
                color: Color(0xFF024D87), size: 18),
            const SizedBox(width: 8),
            Text(
              templateName,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF024D87),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down_rounded,
                color: Color(0xFF024D87), size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  const _SectionLabel(
      {required this.icon, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF024D87)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191C1D),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '· $hint',
          style: GoogleFonts.inter(
              fontSize: 12, color: const Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}

class _EditorField extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final ValueChanged<String> onChanged;

  const _EditorField({
    required this.controller,
    required this.minLines,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF191C1D)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE1E3E4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE1E3E4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF024D87), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Template selector bottom sheet ────────────────────────────────────────────

class _TemplateSheet extends StatefulWidget {
  final void Function(String id, int index) onSelected;
  const _TemplateSheet({required this.onSelected});

  @override
  State<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends State<_TemplateSheet> {
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Tech & AI',
    'Corporate & Finance',
    'Creative & Growth',
    'Healthcare & Service',
    'Remote & Freelance',
    'Entry & Career Shift',
  ];

  Color _accentFor(String id) {
    switch (id) {
      case 'data_science_ai':
      case 'tech_developer': return const Color(0xFF10B981);
      case 'finance_banking': return const Color(0xFFB45309);
      case 'executive_leadership':
      case 'modern_corporate': return const Color(0xFF0F172A);
      case 'creative_design':
      case 'marketing_growth': return const Color(0xFF7C3AED);
      case 'healthcare_nursing': return const Color(0xFF0D9488);
      case 'remote_distributed':
      case 'freelancer_consultant': return const Color(0xFF0284C7);
      case 'entry_level_graduate': return const Color(0xFF2563EB);
      case 'academic_research': return const Color(0xFF1E3A8A);
      default: return const Color(0xFF024D87);
    }
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'data_science_ai': return Icons.psychology_outlined;
      case 'tech_developer': return Icons.code_rounded;
      case 'finance_banking': return Icons.account_balance_outlined;
      case 'executive_leadership': return Icons.workspace_premium_outlined;
      case 'modern_corporate': return Icons.business_outlined;
      case 'creative_design': return Icons.palette_outlined;
      case 'marketing_growth': return Icons.trending_up_rounded;
      case 'healthcare_nursing': return Icons.local_hospital_outlined;
      case 'remote_distributed': return Icons.language_rounded;
      case 'freelancer_consultant': return Icons.laptop_chromebook_rounded;
      case 'entry_level_graduate': return Icons.school_outlined;
      case 'academic_research': return Icons.history_edu_rounded;
      case 'career_change': return Icons.sync_alt_rounded;
      case 'sales_bizdev': return Icons.handshake_outlined;
      case 'customer_success': return Icons.support_agent_rounded;
      default: return Icons.description_outlined;
    }
  }

  String _tagFor(String id) {
    switch (id) {
      case 'data_science_ai': return 'AI & DATA';
      case 'tech_developer': return 'TECH & DEV';
      case 'finance_banking': return 'FINANCE';
      case 'executive_leadership': return 'EXECUTIVE';
      case 'modern_corporate': return 'CORPORATE';
      case 'creative_design': return 'CREATIVE';
      case 'marketing_growth': return 'GROWTH';
      case 'healthcare_nursing': return 'HEALTHCARE';
      case 'remote_distributed': return 'REMOTE';
      case 'freelancer_consultant': return 'FREELANCE';
      case 'entry_level_graduate': return 'GRADUATE';
      case 'academic_research': return 'ACADEMIA';
      case 'career_change': return 'PIVOT';
      case 'sales_bizdev': return 'BIZDEV';
      case 'customer_success': return 'SUPPORT';
      default: return 'STANDARD';
    }
  }

  bool _matchesCategory(String id, String category) {
    if (category == 'All') return true;
    switch (category) {
      case 'Tech & AI':
        return id == 'tech_developer' || id == 'data_science_ai';
      case 'Corporate & Finance':
        return id == 'standard_professional' ||
            id == 'modern_corporate' ||
            id == 'executive_leadership' ||
            id == 'finance_banking';
      case 'Creative & Growth':
        return id == 'creative_design' || id == 'marketing_growth';
      case 'Healthcare & Service':
        return id == 'healthcare_nursing' || id == 'customer_success';
      case 'Remote & Freelance':
        return id == 'remote_distributed' || id == 'freelancer_consultant';
      case 'Entry & Career Shift':
        return id == 'entry_level_graduate' ||
            id == 'career_change' ||
            id == 'academic_research' ||
            id == 'sales_bizdev';
      default:
        return true;
    }
  }

  void _showPreview(BuildContext context, CoverLetterTemplate tpl, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (previewCtx) {
        return Container(
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
                        color: const Color(0xFF024D87).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description_outlined, color: Color(0xFF024D87), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tpl.title,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191C1D),
                            ),
                          ),
                          Text(
                            'Cover Letter Template Preview',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
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

              // Paper Preview
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
                        // Header section with styled border
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            tpl.header.isNotEmpty ? tpl.header : '[Your Name]\n[Contact Information]\n\n[Hiring Team]\n[Company Name]',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF334155),
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Body
                        Text(
                          tpl.body.isNotEmpty ? tpl.body : 'Dear Hiring Manager,\n\nI am writing to express my strong interest in joining your team...',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF1E293B),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Footer
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
                          ),
                          child: Text(
                            tpl.footer.isNotEmpty ? tpl.footer : 'Sincerely,\n[Your Name]',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
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
                        backgroundColor: const Color(0xFF024D87),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(previewCtx);
                        widget.onSelected(tpl.id, index);
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        'Apply This Template',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = context.watch<CoverLetterBloc>().state.model.templateIndex;
    final allTemplates = context.watch<CoverLetterBloc>().state.templates;

    // Filter templates by selected category while preserving original index
    final List<MapEntry<int, CoverLetterTemplate>> indexedTemplates = [];
    for (int i = 0; i < allTemplates.length; i++) {
      if (_matchesCategory(allTemplates[i].id, _selectedCategory)) {
        indexedTemplates.add(MapEntry(i, allTemplates[i]));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: CustomGradientHeader(
            title: 'Choose Your Tone',
            subtitle: 'Select from 16 industry-crafted Cover Letter templates',
            badgeText: '${allTemplates.length} Templates',
            disableTopPadding: true,
            showBackButton: false,
          ),
        ),
        // Horizontal Category Filter Bar
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final isSel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF024D87) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel ? const Color(0xFF024D87) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      if (isSel)
                        BoxShadow(
                          color: const Color(0xFF024D87).withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (allTemplates.isEmpty)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
              itemCount: indexedTemplates.length,
              itemBuilder: (_, listIndex) {
                final originalIndex = indexedTemplates[listIndex].key;
                final tpl = indexedTemplates[listIndex].value;
                final isSelected = originalIndex == current;
                final accent = _accentFor(tpl.id);
                final tag = _tagFor(tpl.id);
                final icon = _iconFor(tpl.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF024D87) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF024D87)
                            : accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : accent,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tpl.title,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: const Color(0xFF191C1D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Tailored industry vocabulary & structure',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                          tooltip: 'Preview Template',
                          color: const Color(0xFF024D87),
                          onPressed: () => _showPreview(context, tpl, originalIndex),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF024D87), size: 22),
                      ],
                    ),
                    onTap: () => widget.onSelected(tpl.id, originalIndex),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

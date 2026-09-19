import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/cv_pdf_generator.dart';
import '../../domain/cv_model.dart';
import '../screens/pdf_preview_screen.dart';

/// Shows an interactive, rich preview modal for any CV template.
void showTemplatePreviewModal({
  required BuildContext context,
  required dynamic template,
  required VoidCallback onUseTemplate,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TemplatePreviewSheet(
      template: template,
      onUseTemplate: () {
        Navigator.pop(ctx);
        onUseTemplate();
      },
    ),
  );
}

class _TemplatePreviewSheet extends StatefulWidget {
  final dynamic template;
  final VoidCallback onUseTemplate;

  const _TemplatePreviewSheet({
    required this.template,
    required this.onUseTemplate,
  });

  @override
  State<_TemplatePreviewSheet> createState() => _TemplatePreviewSheetState();
}

class _TemplatePreviewSheetState extends State<_TemplatePreviewSheet> {
  bool _isGeneratingPdf = false;

  Color _parsePrimaryColor(dynamic template) {
    try {
      final layoutSource = template['layout_source'];
      if (layoutSource is Map && layoutSource['primary_color'] != null) {
        final hex = layoutSource['primary_color'].toString().replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
    } catch (_) {}
    return const Color(0xFF024D87);
  }

  String _getRawLayout(dynamic template) {
    try {
      final layoutSource = widget.template['layout_source'];
      if (layoutSource is Map && layoutSource['layout'] != null) {
        return layoutSource['layout'].toString();
      }
    } catch (_) {}
    return 'single_column';
  }

  String _getLayoutDisplayName(String rawLayout) {
    if (rawLayout == 'sidebar_left') return 'Sidebar Left';
    if (rawLayout == 'two_column') return 'Two Column';
    return 'Classic Single Column';
  }

  String _getFont(dynamic template) {
    try {
      final layoutSource = widget.template['layout_source'];
      if (layoutSource is Map && layoutSource['font'] != null) {
        return layoutSource['font'].toString();
      }
    } catch (_) {}
    return 'Inter';
  }

  TextStyle _getTitleFont(String fontName, {required double size, required FontWeight weight, Color? color}) {
    switch (fontName.toLowerCase()) {
      case 'poppins':
        return GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
      case 'roboto':
        return GoogleFonts.roboto(fontSize: size, fontWeight: weight, color: color);
      case 'merriweather':
      case 'georgia':
        return GoogleFonts.merriweather(fontSize: size, fontWeight: weight, color: color);
      case 'source code pro':
        return GoogleFonts.sourceCodePro(fontSize: size, fontWeight: weight, color: color);
      default:
        return GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color);
    }
  }

  Future<void> _openFullPdfPreview() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final primaryColor = widget.template['layout_source']?['primary_color']?.toString() ?? '#024D87';
      final rawLayout = _getRawLayout(widget.template);
      final sampleCv = CvModel.sample(
        templateId: widget.template['id']?.toString() ?? '',
      );
      final pdfBytes = await CvPdfGenerator().generatePdf(
        sampleCv,
        primaryColorHex: primaryColor,
        layout: rawLayout,
      );

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen.fromBytes(pdfBytes: pdfBytes),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF preview: $e'),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final name = t['name'] ?? 'Template Preview';
    final category = (t['category'] ?? 'Professional').toString().toUpperCase();
    final isPremium = t['is_premium'] == 1 || t['is_premium'] == true;
    final primaryColor = _parsePrimaryColor(t);
    final rawLayout = _getRawLayout(t);
    final layoutDisplayName = _getLayoutDisplayName(rawLayout);
    final fontName = _getFont(t);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Top Bar ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: _getTitleFont(
                                fontName,
                                size: 18,
                                weight: FontWeight.w800,
                                color: const Color(0xFF191C1D),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPremium ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPremium ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isPremium ? 'PRO' : 'FREE',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isPremium ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$category • $layoutDisplayName • Font: $fontName',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Scrollable A4 Document Canvas ─────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildLayoutCanvas(rawLayout, primaryColor, fontName),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Action Bar ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _isGeneratingPdf ? null : _openFullPdfPreview,
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Full PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: primaryColor, width: 1.5),
                        foregroundColor: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: widget.onUseTemplate,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Use This Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layout Switcher ───────────────────────────────────────────────────────

  Widget _buildLayoutCanvas(String rawLayout, Color primaryColor, String fontName) {
    switch (rawLayout) {
      case 'sidebar_left':
        return _buildSidebarLeftLayout(primaryColor, fontName);
      case 'two_column':
        return _buildTwoColumnLayout(primaryColor, fontName);
      case 'single_column':
      default:
        return _buildClassicSingleColumnLayout(primaryColor, fontName);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LAYOUT 1: SIDEBAR LEFT (Creative / Modern Designer)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSidebarLeftLayout(Color primaryColor, String fontName) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left Sidebar (35% width) ──────────────────────────────────────
          Expanded(
            flex: 36,
            child: Container(
              color: primaryColor.withValues(alpha: 0.07),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'TA',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact
                  _sidebarSectionHeader('CONTACT', primaryColor),
                  const SizedBox(height: 8),
                  _sidebarInfoItem(Icons.email_outlined, 'tanvir.ahmed@example.com'),
                  _sidebarInfoItem(Icons.phone_outlined, '+880 1712-345678'),
                  _sidebarInfoItem(Icons.location_on_outlined, 'Dhaka, Bangladesh'),

                  const SizedBox(height: 20),
                  // Personal Info
                  _sidebarSectionHeader('PERSONAL', primaryColor),
                  const SizedBox(height: 8),
                  _sidebarLabelValue('DOB', '15 Jan 1996'),
                  _sidebarLabelValue('Gender', 'Male'),
                  _sidebarLabelValue('Marital', 'Single'),
                  _sidebarLabelValue('Nationality', 'Bangladeshi'),

                  const SizedBox(height: 20),
                  // Skills
                  _sidebarSectionHeader('SKILLS', primaryColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      'Flutter & Dart',
                      'REST APIs',
                      'BLoC Pattern',
                      'Git & CI/CD',
                      'Docker',
                      'Figma',
                    ].map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    )).toList(),
                  ),

                  const SizedBox(height: 20),
                  // Languages
                  _sidebarSectionHeader('LANGUAGES', primaryColor),
                  const SizedBox(height: 8),
                  _sidebarLabelValue('English', 'Professional'),
                  _sidebarLabelValue('Bengali', 'Native'),
                ],
              ),
            ),
          ),

          // ── Right Main Body (65% width) ───────────────────────────────────
          Expanded(
            flex: 64,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mohammad Tanvir Ahmed',
                    style: _getTitleFont(
                      fontName,
                      size: 22,
                      weight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Senior Software Engineer',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Container(
                    height: 2.5,
                    width: 50,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Career Objective
                  _mainSectionTitle('CAREER OBJECTIVE', primaryColor),
                  const SizedBox(height: 6),
                  Text(
                    'Dedicated and results-oriented professional seeking to leverage technical and analytical skills to deliver impactful software architectures and lead engineering teams.',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.45),
                  ),

                  const SizedBox(height: 20),
                  // Education
                  _mainSectionTitle('EDUCATION', primaryColor),
                  const SizedBox(height: 8),
                  _eduRow(
                    degree: 'B.Sc in Computer Science & Engineering',
                    institution: 'University of Dhaka',
                    meta: 'Passing Year: 2019  |  Result: CGPA 3.82',
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _eduRow(
                    degree: 'Higher Secondary Certificate (HSC)',
                    institution: 'Dhaka College (Dhaka Board)',
                    meta: 'Passing Year: 2014  |  Result: GPA 5.00',
                    primaryColor: primaryColor,
                  ),

                  const SizedBox(height: 20),
                  // Work Experience
                  _mainSectionTitle('WORK EXPERIENCE', primaryColor),
                  const SizedBox(height: 8),
                  _timelineWorkItem(
                    role: 'Senior Software Engineer',
                    company: 'TechNova Solutions Ltd.',
                    period: '2021 – Present',
                    bullet: 'Led mobile application architecture; reduced app crash rate to <0.1% and mentored junior developers.',
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _timelineWorkItem(
                    role: 'Software Developer',
                    company: 'InnoApp Labs',
                    period: '2019 – 2021',
                    bullet: 'Developed cross-platform client features and integrated robust offline-first synchronization.',
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LAYOUT 2: TWO COLUMN (Corporate Split / Executive)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTwoColumnLayout(Color primaryColor, String fontName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Width Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: primaryColor, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mohammad Tanvir Ahmed',
                style: _getTitleFont(
                  fontName,
                  size: 24,
                  weight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Senior Software Engineer',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _headerTextItem(Icons.email_outlined, 'tanvir.ahmed@example.com'),
                  _headerTextItem(Icons.phone_outlined, '+880 1712-345678'),
                  _headerTextItem(Icons.location_on_outlined, 'Dhaka, Bangladesh'),
                ],
              ),
            ],
          ),
        ),

        // Two Side-by-Side Columns
        Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Education, Skills, Languages (42%)
              Expanded(
                flex: 42,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _twoColSectionHeader('EDUCATION', primaryColor),
                    const SizedBox(height: 10),
                    _eduCard(
                      degree: 'B.Sc in CSE',
                      institution: 'University of Dhaka',
                      year: '2019',
                      result: 'CGPA 3.82',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 8),
                    _eduCard(
                      degree: 'HSC (Science)',
                      institution: 'Dhaka College (Dhaka Board)',
                      year: '2014',
                      result: 'GPA 5.00',
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 20),
                    _twoColSectionHeader('KEY SKILLS', primaryColor),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        'Flutter & Dart',
                        'RESTful APIs',
                        'State Management',
                        'Git & GitHub',
                        'Clean Architecture',
                        'Agile / Scrum',
                      ].map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      )).toList(),
                    ),

                    const SizedBox(height: 20),
                    _twoColSectionHeader('LANGUAGES', primaryColor),
                    const SizedBox(height: 8),
                    Text('English — Professional Proficiency', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155))),
                    const SizedBox(height: 4),
                    Text('Bengali — Native / Bilingual', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155))),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Right Column: Summary, Experience (58%)
              Expanded(
                flex: 58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _twoColSectionHeader('EXECUTIVE SUMMARY', primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      'Dedicated and results-oriented Software Engineer with extensive experience in architecting high-performance mobile products. Strong record in scalable code, clean patterns, and team collaboration.',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.45),
                    ),

                    const SizedBox(height: 20),
                    _twoColSectionHeader('WORK EXPERIENCE', primaryColor),
                    const SizedBox(height: 10),
                    _expBlock(
                      role: 'Senior Software Engineer',
                      company: 'TechNova Solutions Ltd.',
                      duration: '2021 – Present',
                      bullets: [
                        'Architected and published 3 production apps with >100k downloads.',
                        'Reduced crash rate to <0.1% via robust exception boundaries.',
                        'Mentored junior engineers and conducted weekly design reviews.',
                      ],
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _expBlock(
                      role: 'Software Developer',
                      company: 'InnoApp Labs',
                      duration: '2019 – 2021',
                      bullets: [
                        'Implemented responsive UI screens and integrated REST endpoints.',
                        'Built offline cache handling with SQLite and secure storage.',
                      ],
                      primaryColor: primaryColor,
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

  // ══════════════════════════════════════════════════════════════════════════
  // LAYOUT 3: CLASSIC SINGLE COLUMN (Formal / Academic / Government)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildClassicSingleColumnLayout(Color primaryColor, String fontName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered Formal Header
          Center(
            child: Column(
              children: [
                Text(
                  'MOHAMMAD TANVIR AHMED',
                  style: _getTitleFont(
                    fontName,
                    size: 20,
                    weight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'tanvir.ahmed@example.com  |  +880 1712-345678  |  Dhaka, Bangladesh',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1.5,
                  color: primaryColor,
                ),
                const SizedBox(height: 2),
                Container(
                  height: 0.5,
                  color: const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Career Objective
          _classicSectionTitle('CAREER OBJECTIVE', primaryColor),
          const SizedBox(height: 6),
          Text(
            'To secure a challenging position where I can effectively contribute my skills as a software engineer, enhance technical excellence, and drive strategic product value.',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.5),
          ),

          const SizedBox(height: 18),
          // Education
          _classicSectionTitle('EDUCATION & ACADEMIC BACKGROUND', primaryColor),
          const SizedBox(height: 8),
          _classicEduRow(
            degree: 'B.Sc in Computer Science & Engineering',
            institution: 'University of Dhaka',
            board: 'Dhaka',
            year: '2019',
            result: 'CGPA 3.82',
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 6),
          _classicEduRow(
            degree: 'Higher Secondary Certificate (HSC)',
            institution: 'Dhaka College',
            board: 'Dhaka Board',
            year: '2014',
            result: 'GPA 5.00',
            primaryColor: primaryColor,
          ),

          const SizedBox(height: 18),
          // Work Experience
          _classicSectionTitle('WORK EXPERIENCE', primaryColor),
          const SizedBox(height: 8),
          _classicWorkRow(
            role: 'Senior Software Engineer',
            company: 'TechNova Solutions Ltd.',
            period: '2021 – Present',
            desc: 'Spearheaded frontend architecture and scalable state management for customer-facing mobile applications.',
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 6),
          _classicWorkRow(
            role: 'Software Developer',
            company: 'InnoApp Labs',
            period: '2019 – 2021',
            desc: 'Developed REST API client integrations, complex UI widgets, and unit test suites.',
            primaryColor: primaryColor,
          ),

          const SizedBox(height: 18),
          // Skills
          _classicSectionTitle('TECHNICAL SKILLS', primaryColor),
          const SizedBox(height: 8),
          Text(
            'Languages & Frameworks: Flutter, Dart, Java, Python, SQL\nTools & Platforms: Git, GitHub, Docker, Postman, Figma, Firebase',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.5),
          ),

          const SizedBox(height: 18),
          // Languages
          _classicSectionTitle('LANGUAGES', primaryColor),
          const SizedBox(height: 6),
          Text(
            'English (Professional Working Proficiency), Bengali (Native / Bilingual)',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  // ── Helper Subwidgets ─────────────────────────────────────────────────────

  Widget _sidebarSectionHeader(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: color),
    );
  }

  Widget _sidebarInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF334155))),
          ),
        ],
      ),
    );
  }

  Widget _sidebarLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF1E293B), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _mainSectionTitle(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: color),
    );
  }

  Widget _eduRow({required String degree, required String institution, required String meta, required Color primaryColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(degree, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
          Text(institution, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
          const SizedBox(height: 2),
          Text(meta, style: GoogleFonts.inter(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _timelineWorkItem({required String role, required String company, required String period, required String bullet, required Color primaryColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(role, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                  Text(period, style: GoogleFonts.inter(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
              Text(company, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
              const SizedBox(height: 3),
              Text(bullet, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155), height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerTextItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Text(text, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _twoColSectionHeader(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: color)),
        const SizedBox(height: 4),
        Container(height: 2, width: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _eduCard({required String degree, required String institution, required String year, required String result, required Color primaryColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(degree, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
          Text(institution, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF475569))),
          const SizedBox(height: 2),
          Text('$year  •  $result', style: GoogleFonts.inter(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _expBlock({required String role, required String company, required String duration, required List<String> bullets, required Color primaryColor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(role, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
              Text(duration, style: GoogleFonts.inter(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(company, style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: const Color(0xFF475569))),
          const SizedBox(height: 4),
          ...bullets.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Expanded(child: Text(b, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155), height: 1.3))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _classicSectionTitle(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color, width: 1.2)),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: color),
      ),
    );
  }

  Widget _classicEduRow({required String degree, required String institution, required String board, required String year, required String result, required Color primaryColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(degree, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
              Text('$institution ($board)', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF475569))),
            ],
          ),
        ),
        Text('$year | $result', style: GoogleFonts.inter(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _classicWorkRow({required String role, required String company, required String period, required String desc, required Color primaryColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            Text(period, style: GoogleFonts.inter(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(company, style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: const Color(0xFF475569))),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF334155), height: 1.35)),
      ],
    );
  }
}

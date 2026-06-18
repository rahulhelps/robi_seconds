import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/sop_model.dart';
import '../bloc/sop_bloc.dart';
import '../widgets/sop_form_widgets.dart';
import 'sop_output_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SopScreen — provides SopBloc and delegates rendering to _SopFormView.
// ─────────────────────────────────────────────────────────────────────────────

class SopScreen extends StatelessWidget {
  final String templateId;
  final String templateName;

  const SopScreen({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  @override
  Widget build(BuildContext context) {
    return _SopFormView(templateId: templateId, templateName: templateName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SopFormView — stateful form with gradient header, styled cards, inputs
// ─────────────────────────────────────────────────────────────────────────────

class _SopFormView extends StatefulWidget {
  final String templateId;
  final String templateName;

  const _SopFormView({
    required this.templateId,
    required this.templateName,
  });

  @override
  State<_SopFormView> createState() => _SopFormViewState();
}

class _SopFormViewState extends State<_SopFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _optionalExpanded = false;

  // Required controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _programCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _countryCtrl;

  // Optional controllers
  late final TextEditingController _academicBgCtrl;
  late final TextEditingController _gpaCtrl;
  late final TextEditingController _workExpCtrl;
  late final TextEditingController _researchCtrl;
  late final TextEditingController _skillsCtrl;
  late final TextEditingController _goalsCtrl;
  late final TextEditingController _achievementsCtrl;
  late final TextEditingController _whyUniCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl        = TextEditingController();
    _programCtrl     = TextEditingController();
    _universityCtrl  = TextEditingController();
    _countryCtrl     = TextEditingController();
    _academicBgCtrl  = TextEditingController();
    _gpaCtrl         = TextEditingController();
    _workExpCtrl     = TextEditingController();
    _researchCtrl    = TextEditingController();
    _skillsCtrl      = TextEditingController();
    _goalsCtrl       = TextEditingController();
    _achievementsCtrl = TextEditingController();
    _whyUniCtrl      = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _programCtrl.dispose();
    _universityCtrl.dispose();
    _countryCtrl.dispose();
    _academicBgCtrl.dispose();
    _gpaCtrl.dispose();
    _workExpCtrl.dispose();
    _researchCtrl.dispose();
    _skillsCtrl.dispose();
    _goalsCtrl.dispose();
    _achievementsCtrl.dispose();
    _whyUniCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final model = SopModel(
        name: _nameCtrl.text.trim(),
        programName: _programCtrl.text.trim(),
        universityName: _universityCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        templateId: widget.templateId,
        academicBackground: _optStr(_academicBgCtrl),
        gpa: _optStr(_gpaCtrl),
        workExperience: _optStr(_workExpCtrl),
        researchExperience: _optStr(_researchCtrl),
        skills: _optStr(_skillsCtrl),
        goals: _optStr(_goalsCtrl),
        achievements: _optStr(_achievementsCtrl),
        whyThisUniversity: _optStr(_whyUniCtrl),
      );
      context.read<SopBloc>().add(SopGenerateRequested(model));
    }
  }

  String? _optStr(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SopBloc, SopState>(
      listener: (context, state) {
        if (state is SopSuccess && state.savedSop != null) {
          final bloc = context.read<SopBloc>();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: SopOutputScreen(
                  saved: state.savedSop!,
                  pdfBytes: state.pdfBytes,
                  model: state.model,
                  generatedPayload: state.generatedPayload,
                ),
              ),
            ),
          );
        } else if (state is SopFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            ));
        }
      },
      builder: (context, state) {
        final isLoading = state is SopLoading;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                // ── Gradient Header ────────────────────────────────────────
                _SopScreenHeader(templateName: widget.templateName),

                // ── Scrollable Form ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Required fields card
                          _RequiredFieldsCard(
                            nameCtrl: _nameCtrl,
                            programCtrl: _programCtrl,
                            universityCtrl: _universityCtrl,
                            countryCtrl: _countryCtrl,
                            templateName: widget.templateName,
                          ),

                          const SizedBox(height: 16),

                          // Optional fields card
                          _OptionalFieldsCard(
                            expanded: _optionalExpanded,
                            onToggle: () => setState(
                                () => _optionalExpanded = !_optionalExpanded),
                            academicBgCtrl: _academicBgCtrl,
                            gpaCtrl: _gpaCtrl,
                            workExpCtrl: _workExpCtrl,
                            researchCtrl: _researchCtrl,
                            skillsCtrl: _skillsCtrl,
                            goalsCtrl: _goalsCtrl,
                            achievementsCtrl: _achievementsCtrl,
                            whyUniCtrl: _whyUniCtrl,
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Fixed Bottom Button ────────────────────────────────────
                SopGenerateButton(
                  isLoading: isLoading,
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SopScreenHeader — gradient app bar with back button
// ─────────────────────────────────────────────────────────────────────────────

class _SopScreenHeader extends StatelessWidget {
  final String templateName;

  const _SopScreenHeader({required this.templateName});

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  templateName,
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
                  'Statement of Purpose',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Fill in your details below to generate your SOP',
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
// _RequiredFieldsCard — white card with blue left accent, "Required" badge
// ─────────────────────────────────────────────────────────────────────────────

class _RequiredFieldsCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController programCtrl;
  final TextEditingController universityCtrl;
  final TextEditingController countryCtrl;
  final String templateName;

  const _RequiredFieldsCard({
    required this.nameCtrl,
    required this.programCtrl,
    required this.universityCtrl,
    required this.countryCtrl,
    required this.templateName,
  });

  @override
  Widget build(BuildContext context) {
    return SopCard(
      leftAccentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SopSectionHeader(
            title: 'Required Information',
            badge: const RequiredBadge(),
          ),
          const SizedBox(height: 18),
          SopFormField(
            controller: nameCtrl,
            label: 'Full Name',
            hint: 'e.g. John Doe',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 16),
          SopFormField(
            controller: programCtrl,
            label: 'Program / Degree Name',
            hint: 'e.g. MSc in Computer Science',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter the program name'
                : null,
          ),
          const SizedBox(height: 16),
          SopFormField(
            controller: universityCtrl,
            label: 'University Name',
            hint: 'e.g. University of Oxford',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter the university name'
                : null,
          ),
          const SizedBox(height: 16),
          SopFormField(
            controller: countryCtrl,
            label: 'Target Country',
            hint: 'e.g. United Kingdom',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter the country'
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OptionalFieldsCard — expandable card with animated chevron
// ─────────────────────────────────────────────────────────────────────────────

class _OptionalFieldsCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final TextEditingController academicBgCtrl;
  final TextEditingController gpaCtrl;
  final TextEditingController workExpCtrl;
  final TextEditingController researchCtrl;
  final TextEditingController skillsCtrl;
  final TextEditingController goalsCtrl;
  final TextEditingController achievementsCtrl;
  final TextEditingController whyUniCtrl;

  const _OptionalFieldsCard({
    required this.expanded,
    required this.onToggle,
    required this.academicBgCtrl,
    required this.gpaCtrl,
    required this.workExpCtrl,
    required this.researchCtrl,
    required this.skillsCtrl,
    required this.goalsCtrl,
    required this.achievementsCtrl,
    required this.whyUniCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SopCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header / toggle row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optional Details',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Add more context for a better SOP',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 18),
                  SopFormField(
                    controller: academicBgCtrl,
                    label: 'Academic Background',
                    hint: 'Details of your previous degree / subjects',
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: gpaCtrl,
                    label: 'GPA / Score',
                    hint: 'e.g. 3.9/4.0 or 85%',
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: workExpCtrl,
                    label: 'Work Experience',
                    hint: 'Summarize your professional experience / roles',
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: researchCtrl,
                    label: 'Research Experience / Projects',
                    hint: 'Describe any thesis, publications, or key projects',
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: skillsCtrl,
                    label: 'Key Skills',
                    hint: 'e.g. Machine Learning, Public Speaking, Agile',
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: goalsCtrl,
                    label: 'Career Goals',
                    hint: 'Short-term and long-term career goals',
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: achievementsCtrl,
                    label: 'Achievements / Awards',
                    hint: "e.g. Dean's List, National Hackathon Winner",
                  ),
                  const SizedBox(height: 16),
                  SopFormField(
                    controller: whyUniCtrl,
                    label: 'Why This University / Program?',
                    hint: 'Specific reasons you chose this university',
                    minLines: 3,
                  ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

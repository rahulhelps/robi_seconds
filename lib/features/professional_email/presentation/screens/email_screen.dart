import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/email_model.dart';
import '../bloc/email_bloc.dart';
import 'email_output_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmailScreen — form screen following EXACT same pattern as SopScreen.
// Gradient header, required card, optional expandable card, generate button.
// ─────────────────────────────────────────────────────────────────────────────

class EmailScreen extends StatelessWidget {
  final String templateId;
  final String templateName;

  const EmailScreen({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  @override
  Widget build(BuildContext context) {
    return _EmailFormView(
        templateId: templateId, templateName: templateName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmailFormView — stateful form with gradient header + styled cards
// ─────────────────────────────────────────────────────────────────────────────

class _EmailFormView extends StatefulWidget {
  final String templateId;
  final String templateName;

  const _EmailFormView({
    required this.templateId,
    required this.templateName,
  });

  @override
  State<_EmailFormView> createState() => _EmailFormViewState();
}

class _EmailFormViewState extends State<_EmailFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _optionalExpanded = false;

  // Required controllers
  late final TextEditingController _emailTypeCtrl;
  late final TextEditingController _senderNameCtrl;
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _recipientDesigCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _subjectCtrl;

  // Optional controllers
  late final TextEditingController _senderDesigCtrl;
  late final TextEditingController _senderCompanyCtrl;
  late final TextEditingController _keyPointsCtrl;
  late final TextEditingController _specificRequestCtrl;
  late final TextEditingController _deadlineCtrl;

  String _selectedEmailType = EmailTypes.all.first;

  @override
  void initState() {
    super.initState();
    _emailTypeCtrl = TextEditingController(text: EmailTypes.all.first);
    _senderNameCtrl = TextEditingController();
    _recipientNameCtrl = TextEditingController();
    _recipientDesigCtrl = TextEditingController();
    _companyCtrl = TextEditingController();
    _subjectCtrl = TextEditingController();
    _senderDesigCtrl = TextEditingController();
    _senderCompanyCtrl = TextEditingController();
    _keyPointsCtrl = TextEditingController();
    _specificRequestCtrl = TextEditingController();
    _deadlineCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailTypeCtrl.dispose();
    _senderNameCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientDesigCtrl.dispose();
    _companyCtrl.dispose();
    _subjectCtrl.dispose();
    _senderDesigCtrl.dispose();
    _senderCompanyCtrl.dispose();
    _keyPointsCtrl.dispose();
    _specificRequestCtrl.dispose();
    _deadlineCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final model = EmailModel(
        emailType: _selectedEmailType,
        senderName: _senderNameCtrl.text.trim(),
        recipientName: _recipientNameCtrl.text.trim(),
        recipientDesignation: _recipientDesigCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        templateId: widget.templateId,
        senderDesignation: _optStr(_senderDesigCtrl),
        senderCompany: _optStr(_senderCompanyCtrl),
        keyPoints: _optStr(_keyPointsCtrl),
        specificRequest: _optStr(_specificRequestCtrl),
        deadline: _optStr(_deadlineCtrl),
      );
      context.read<EmailBloc>().add(EmailGenerateRequested(model));
    }
  }

  String? _optStr(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmailBloc, EmailState>(
      listener: (context, state) {
        if (state is EmailSuccess && state.pdfBytes != null) {
          final bloc = context.read<EmailBloc>();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: EmailOutputScreen(
                  savedEmail: state.savedEmail,
                  pdfBytes: state.pdfBytes!,
                  model: state.model,
                  generatedBody: state.generatedBody,
                ),
              ),
            ),
          );
        } else if (state is EmailFailure) {
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
        final isLoading = state is EmailLoading;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                // ── Gradient Header — EXACT same as SopScreen ──────────────
                _EmailScreenHeader(templateName: widget.templateName),

                // ── Scrollable Form ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email type selector card
                          _EmailTypeCard(
                            selectedType: _selectedEmailType,
                            onTypeChanged: (val) =>
                                setState(() => _selectedEmailType = val),
                          ),

                          const SizedBox(height: 16),

                          // Required fields card
                          _RequiredFieldsCard(
                            senderNameCtrl: _senderNameCtrl,
                            recipientNameCtrl: _recipientNameCtrl,
                            recipientDesigCtrl: _recipientDesigCtrl,
                            companyCtrl: _companyCtrl,
                            subjectCtrl: _subjectCtrl,
                          ),

                          const SizedBox(height: 16),

                          // Optional fields card
                          _OptionalFieldsCard(
                            expanded: _optionalExpanded,
                            onToggle: () => setState(
                                () => _optionalExpanded = !_optionalExpanded),
                            senderDesigCtrl: _senderDesigCtrl,
                            senderCompanyCtrl: _senderCompanyCtrl,
                            keyPointsCtrl: _keyPointsCtrl,
                            specificRequestCtrl: _specificRequestCtrl,
                            deadlineCtrl: _deadlineCtrl,
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Fixed Bottom Button ────────────────────────────────────
                _EmailGenerateButton(
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
// _EmailScreenHeader — EXACT same gradient header as SopScreen
// ─────────────────────────────────────────────────────────────────────────────

class _EmailScreenHeader extends StatelessWidget {
  final String templateName;

  const _EmailScreenHeader({required this.templateName});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(4, topPadding + 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  'Professional Email',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Fill in your details below to generate your email',
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
// _EmailTypeCard — dropdown selector for email type
// ─────────────────────────────────────────────────────────────────────────────

class _EmailTypeCard extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const _EmailTypeCard({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
            left: BorderSide(color: Color(0xFF51B1E1), width: 4)),
        boxShadow: const [
          BoxShadow(
              blurRadius: 12, color: Colors.black12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Email Type',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF51B1E1)),
                ),
                child: Text(
                  'Select One',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary),
                dropdownColor: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                items: EmailTypes.all
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) onTypeChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RequiredFieldsCard — white card with blue left accent + Required badge
// ─────────────────────────────────────────────────────────────────────────────

class _RequiredFieldsCard extends StatelessWidget {
  final TextEditingController senderNameCtrl;
  final TextEditingController recipientNameCtrl;
  final TextEditingController recipientDesigCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController subjectCtrl;

  const _RequiredFieldsCard({
    required this.senderNameCtrl,
    required this.recipientNameCtrl,
    required this.recipientDesigCtrl,
    required this.companyCtrl,
    required this.subjectCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _EmailCard(
      leftAccentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Required Information',
            badge: const _RequiredBadge(),
          ),
          const SizedBox(height: 18),
          _EmailFormField(
            controller: senderNameCtrl,
            label: 'Your Full Name',
            hint: 'e.g. John Doe',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 16),
          _EmailFormField(
            controller: recipientNameCtrl,
            label: 'Recipient Name',
            hint: 'e.g. Jane Smith',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter recipient name'
                : null,
          ),
          const SizedBox(height: 16),
          _EmailFormField(
            controller: recipientDesigCtrl,
            label: 'Recipient Designation',
            hint: 'e.g. HR Manager, CEO, Professor',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter recipient designation'
                : null,
          ),
          const SizedBox(height: 16),
          _EmailFormField(
            controller: companyCtrl,
            label: 'Company / Institution',
            hint: 'e.g. Google Inc., Harvard University',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter company name'
                : null,
          ),
          const SizedBox(height: 16),
          _EmailFormField(
            controller: subjectCtrl,
            label: 'Email Subject',
            hint: 'e.g. Application for Software Engineer Position',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter the email subject'
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
  final TextEditingController senderDesigCtrl;
  final TextEditingController senderCompanyCtrl;
  final TextEditingController keyPointsCtrl;
  final TextEditingController specificRequestCtrl;
  final TextEditingController deadlineCtrl;

  const _OptionalFieldsCard({
    required this.expanded,
    required this.onToggle,
    required this.senderDesigCtrl,
    required this.senderCompanyCtrl,
    required this.keyPointsCtrl,
    required this.specificRequestCtrl,
    required this.deadlineCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _EmailCard(
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
                          'Add more context for a better email',
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
                  _EmailFormField(
                    controller: senderDesigCtrl,
                    label: 'Your Designation',
                    hint: 'e.g. Software Engineer, Student',
                  ),
                  const SizedBox(height: 16),
                  _EmailFormField(
                    controller: senderCompanyCtrl,
                    label: 'Your Company / Institution',
                    hint: 'e.g. Microsoft, MIT',
                  ),
                  const SizedBox(height: 16),
                  _EmailFormField(
                    controller: keyPointsCtrl,
                    label: 'Key Points to Include',
                    hint: 'Main points you want highlighted in the email',
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _EmailFormField(
                    controller: specificRequestCtrl,
                    label: 'Specific Request',
                    hint: 'What specifically are you asking for?',
                    minLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _EmailFormField(
                    controller: deadlineCtrl,
                    label: 'Response Deadline',
                    hint: 'e.g. July 15, 2025 or ASAP',
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

// ─────────────────────────────────────────────────────────────────────────────
// _EmailGenerateButton — fixed bottom gradient button
// ─────────────────────────────────────────────────────────────────────────────

class _EmailGenerateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _EmailGenerateButton({
    required this.isLoading,
    required this.onPressed,
  });

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
              gradient: isLoading
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isLoading
                  ? AppColors.primaryDark.withValues(alpha: 0.5)
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isLoading
                  ? null
                  : [
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
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 20),
              label: Text(
                isLoading ? 'Generating Email…' : 'Generate Email  →',
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared reusable widgets for EmailScreen
// ─────────────────────────────────────────────────────────────────────────────

/// White card with soft shadow — wraps any content.
class _EmailCard extends StatelessWidget {
  final Widget child;
  final Color? leftAccentColor;
  final EdgeInsets padding;

  const _EmailCard({
    required this.child,
    this.leftAccentColor,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: leftAccentColor != null
            ? Border(left: BorderSide(color: leftAccentColor!, width: 4))
            : null,
        boxShadow: const [
          BoxShadow(
              blurRadius: 12, color: Colors.black12, offset: Offset(0, 4)),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Section header row with title and optional trailing badge widget.
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? badge;

  const _SectionHeader({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (badge != null) badge!,
      ],
    );
  }
}

/// "Required" badge pill.
class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB3B3)),
      ),
      child: Text(
        'Required',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      ),
    );
  }
}

/// Styled TextFormField used throughout email form.
class _EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final String? Function(String?)? validator;

  const _EmailFormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          minLines: minLines,
          maxLines: minLines > 1 ? null : 1,
          keyboardType:
              minLines > 1 ? TextInputType.multiline : TextInputType.text,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.inter(fontSize: 13, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

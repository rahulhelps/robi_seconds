import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/cv_bloc.dart';
import '../../../../core/widgets/custom_gradient_header.dart';
import 'pdf_preview_screen.dart';

class AiCvGeneratorScreen extends StatefulWidget {
  final String? selectedTemplateId;
  final String? selectedTemplateName;

  const AiCvGeneratorScreen({
    super.key,
    this.selectedTemplateId,
    this.selectedTemplateName,
  });

  @override
  State<AiCvGeneratorScreen> createState() => _AiCvGeneratorScreenState();
}

class _AiCvGeneratorScreenState extends State<AiCvGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _industryController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  final _skillsController = TextEditingController();

  String _experienceLevel = 'mid';
  int _yearsOfExperience = 3;
  String _educationLevel = 'bachelor';

  @override
  void dispose() {
    _jobTitleController.dispose();
    _industryController.dispose();
    _additionalDetailsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    context.read<CvBloc>().add(GenerateCvWithAi(
      jobTitle: _jobTitleController.text.trim(),
      industry: _industryController.text.trim(),
      experienceLevel: _experienceLevel,
      yearsOfExperience: _yearsOfExperience,
      keySkills: skills,
      educationLevel: _educationLevel,
      additionalDetails: _additionalDetailsController.text.trim(),
      templateId: widget.selectedTemplateId,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              title: 'AI CV Generator',
              subtitle: 'Let AI build a professional CV for you',
              badgeText: widget.selectedTemplateName ?? 'AI Powered',
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: BlocListener<CvBloc, CvState>(
                listener: (context, state) {
                  if (state is CvLoaded && state.cvId != null) {
                    context.read<CvBloc>().add(const FetchCVs());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewScreen.fromId(
                          cvId: state.cvId!,
                          bearerToken: state.token ?? '',
                        ),
                      ),
                    );
                  } else if (state is CvError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: const Color(0xFFBA1A1A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tell us about your career',
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF191C1D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The more details you provide, the better your CV will be.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF3E4A3C),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildJobTitleField(),
                            const SizedBox(height: 20),
                            _buildIndustryField(),
                            const SizedBox(height: 20),
                            _buildExperienceSection(),
                            const SizedBox(height: 20),
                            _buildSkillsField(),
                            const SizedBox(height: 20),
                            _buildEducationSection(),
                            const SizedBox(height: 20),
                            _buildAdditionalDetailsField(),
                            const SizedBox(height: 32),
                            _buildGenerateButton(context),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTitleField() {
    return TextFormField(
      controller: _jobTitleController,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Job title is required' : null,
      decoration: InputDecoration(
        labelText: 'Job Title / Position',
        hintText: 'e.g. Software Engineer, Accountant, Marketing Manager',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildIndustryField() {
    return TextFormField(
      controller: _industryController,
      decoration: InputDecoration(
        labelText: 'Industry',
        hintText: 'e.g. Technology, Finance, Healthcare',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Level',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'junior', label: Text('Junior'), icon: Icon(Icons.school_outlined)),
            ButtonSegment(value: 'mid', label: Text('Mid'), icon: Icon(Icons.work_outline)),
            ButtonSegment(value: 'senior', label: Text('Senior'), icon: Icon(Icons.leaderboard_outlined)),
            ButtonSegment(value: 'executive', label: Text('Executive'), icon: Icon(Icons.corporate_fare)),
          ],
          selected: {_experienceLevel},
          onSelectionChanged: (Set<String> selection) {
            setState(() => _experienceLevel = selection.first);
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Years of Experience: $_yearsOfExperience',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        Slider(
          value: _yearsOfExperience.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '$_yearsOfExperience years',
          onChanged: (v) => setState(() => _yearsOfExperience = v.round()),
        ),
      ],
    );
  }

  Widget _buildSkillsField() {
    return TextFormField(
      controller: _skillsController,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'At least one skill is required' : null,
      decoration: InputDecoration(
        labelText: 'Key Skills',
        hintText: 'e.g. JavaScript, React, Node.js, Project Management',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highest Education',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
      initialValue: _educationLevel,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'high_school', child: Text('High School')),
        DropdownMenuItem(value: 'bachelor', child: Text("Bachelor's Degree")),
        DropdownMenuItem(value: 'master', child: Text("Master's Degree")),
        DropdownMenuItem(value: 'phd', child: Text('PhD')),
        DropdownMenuItem(value: 'diploma', child: Text('Diploma / Certification')),
      ],
      onChanged: (v) => setState(() => _educationLevel = v ?? _educationLevel),
    ),
      ],
    );
  }

  Widget _buildAdditionalDetailsField() {
    return TextFormField(
      controller: _additionalDetailsController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Additional Details (optional)',
        hintText: 'Any achievements, projects, or notable experiences...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final isLoading = state is CvLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF024D87),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Generate CV with AI',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }
}


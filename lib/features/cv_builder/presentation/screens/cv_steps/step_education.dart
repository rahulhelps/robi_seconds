import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';
import '../../../../../core/services/backend_service.dart';

class StepEducation extends StatefulWidget {
  final VoidCallback onNext;
  const StepEducation({super.key, required this.onNext});

  @override
  State<StepEducation> createState() => _StepEducationState();
}

class _StepEducationState extends State<StepEducation> {
  final BackendService _backendService = BackendService();
  List<String> _levels = [];
  List<String> _boards = [];
  List<String> _groups = [];
  List<String> _institutions = [];
  List<String> _years = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initYears();
    _loadEducationData();
  }

  void _initYears() {
    final currentYear = DateTime.now().year + 4; // allow upcoming grads
    _years = List.generate(
      currentYear - 1969,
      (index) => (currentYear - index).toString(),
    );
  }

  Future<void> _loadEducationData() async {
    final data = await _backendService.getEducationData();

    if (mounted) {
      setState(() {
        final rawLevels = (data['levels'] as List<dynamic>?) ?? [];
        _levels = rawLevels
            .map((e) => e is Map ? e['name'].toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
        if (_levels.isEmpty) {
          _levels = [
            'SSC',
            'Dakhil',
            'HSC',
            'Alim',
            'Diploma (Polytechnic)',
            'Honors/Bachelor',
            'Masters',
            'PhD',
            'O-Level',
            'A-Level',
          ];
        }

        final rawBoards = (data['boards'] as List<dynamic>?) ?? [];
        _boards = rawBoards
            .map((e) => e is Map ? e['name'].toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
        if (_boards.isEmpty) {
          _boards = [
            'Dhaka',
            'Rajshahi',
            'Comilla',
            'Jessore',
            'Chittagong',
            'Sylhet',
            'Barisal',
            'Dinajpur',
            'Mymensingh',
            'Madrasah Education Board',
            'Bangladesh Technical Education Board (BTEB)',
            'Other / Autonomous',
          ];
        }

        final rawGroups = (data['groups'] as List<dynamic>?) ?? [];
        _groups = rawGroups
            .map((e) => e is Map ? e['name'].toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
        if (_groups.isEmpty) {
          _groups = [
            'Science',
            'Commerce (Business Studies)',
            'Humanities/Arts',
            'Vocational',
            'General',
          ];
        }

        final rawInst = (data['institutions'] as List<dynamic>?) ?? [];
        _institutions = rawInst
            .map((e) => e is Map ? e['name'].toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList();

        _isLoading = false;
      });

      // If no education entries exist yet, auto-add the first one
      final currentEducation = context.read<CvBloc>().state.model.education;
      if (currentEducation.isEmpty) {
        context.read<CvBloc>().add(const CvAddEducation());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(color: Color(0xFF024D87)),
        ),
      );
    }

    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final educationList = state.model.education;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CvStepHeader(
                    title: 'Education',
                    subtitle:
                        'Add your academic qualifications. Level, board, year, and institution are mandatory.',
                    icon: Icons.school_rounded,
                  ),
                  if (educationList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No education entries added yet.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...List.generate(educationList.length, (i) {
                    return _EducationCard(
                      index: i,
                      levels: _levels,
                      boards: _boards,
                      groups: _groups,
                      years: _years,
                      institutions: _institutions,
                      totalCount: educationList.length,
                    );
                  }),
                  const SizedBox(height: 12),
                  CvAddButton(
                    label: 'Add Another Education',
                    onTap: () =>
                        context.read<CvBloc>().add(const CvAddEducation()),
                  ),
                  const SizedBox(height: 32),
                  CvNextButton(onNext: widget.onNext),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EducationCard extends StatefulWidget {
  final int index;
  final List<String> levels;
  final List<String> boards;
  final List<String> groups;
  final List<String> years;
  final List<String> institutions;
  final int totalCount;

  const _EducationCard({
    required this.index,
    required this.levels,
    required this.boards,
    required this.groups,
    required this.years,
    required this.institutions,
    required this.totalCount,
  });

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  late final TextEditingController _resultController;
  late final TextEditingController _fieldController;

  @override
  void initState() {
    super.initState();
    final edu = context.read<CvBloc>().state.model.education[widget.index];
    _resultController = TextEditingController(text: edu.result);
    _fieldController = TextEditingController(text: edu.fieldOfStudy);
  }

  @override
  void dispose() {
    _resultController.dispose();
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final edu = state.model.education[widget.index];
        final showErrors = state.showErrors;

        // Sync controllers only when model value differs (e.g. after external reset)
        if (_resultController.text != edu.result) {
          _resultController.value = TextEditingValue(
            text: edu.result,
            selection: TextSelection.collapsed(offset: edu.result.length),
          );
        }
        if (_fieldController.text != edu.fieldOfStudy) {
          _fieldController.value = TextEditingValue(
            text: edu.fieldOfStudy,
            selection: TextSelection.collapsed(offset: edu.fieldOfStudy.length),
          );
        }

        final levelError = showErrors && edu.degree.trim().isEmpty
            ? 'Education level is required'
            : null;
        final boardError = showErrors && edu.board.trim().isEmpty
            ? 'Board / University is required'
            : null;
        final yearError = showErrors &&
                edu.endDate.trim().isEmpty &&
                edu.passingYear.trim().isEmpty
            ? 'Passing year is required'
            : null;
        final instError = showErrors && edu.institution.trim().isEmpty
            ? 'Institution name is required'
            : null;

        // Ensure safe value or null for Dropdowns
        final selectedLevel = widget.levels.contains(edu.degree) ? edu.degree : null;
        final selectedBoard = widget.boards.contains(edu.board) ? edu.board : null;
        final currentYear = edu.passingYear.isNotEmpty
            ? edu.passingYear
            : edu.endDate;
        final selectedYear = widget.years.contains(currentYear) ? currentYear : null;

        return CvEntryCard(
          index: widget.index,
          title: edu.degree.isNotEmpty
              ? '${edu.degree} Qualification'
              : 'Education #${widget.index + 1}',
          icon: Icons.school_outlined,
          onRemove: () => context.read<CvBloc>().add(CvRemoveEducation(widget.index)),
          fields: [
            // 1. Education Level (Mandatory Dropdown)
            CvDropdownField(
              label: 'Education Level / Degree',
              value: selectedLevel,
              options: widget.levels,
              isRequired: true,
              prefixIcon: Icons.workspace_premium_outlined,
              hint: 'Select Education Level (e.g. SSC, HSC, Bachelor)',
              errorText: levelError,
              onChanged: (v) {
                if (v != null) {
                  context
                      .read<CvBloc>()
                      .add(CvUpdateEducation(widget.index, 'degree', v));
                }
              },
            ),

            // 2. Board / University (Mandatory Dropdown)
            CvDropdownField(
              label: 'Education Board / University',
              value: selectedBoard,
              options: widget.boards,
              isRequired: true,
              prefixIcon: Icons.account_balance_outlined,
              hint: 'Select Education Board (e.g. Dhaka, BTEB)',
              errorText: boardError,
              onChanged: (v) {
                if (v != null) {
                  context
                      .read<CvBloc>()
                      .add(CvUpdateEducation(widget.index, 'board', v));
                }
              },
            ),

            // 3. Passing Year (Mandatory Dropdown) & Result
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: CvDropdownField(
                    label: 'Passing Year',
                    value: selectedYear,
                    options: widget.years,
                    isRequired: true,
                    prefixIcon: Icons.calendar_today_rounded,
                    hint: 'Select Year',
                    errorText: yearError,
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<CvBloc>()
                            .add(CvUpdateEducation(widget.index, 'passingYear', v));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: CvTextField(
                    label: 'Result / GPA',
                    hint: 'e.g. GPA 5.00',
                    prefixIcon: Icons.grade_outlined,
                    controller: _resultController,
                    onChanged: (v) => context
                        .read<CvBloc>()
                        .add(CvUpdateEducation(widget.index, 'result', v)),
                  ),
                ),
              ],
            ),

            // 4. Institution (Autocomplete + Manual Entry, Mandatory)
            Autocomplete<String>(
              initialValue: TextEditingValue(text: edu.institution),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.trim().isEmpty) {
                  return widget.institutions.take(6);
                }
                return widget.institutions.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                context
                    .read<CvBloc>()
                    .add(CvUpdateEducation(widget.index, 'institution', selection));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return CvTextField(
                  label: 'Institution / School / College',
                  hint: 'e.g. Dhaka College, University of Dhaka',
                  prefixIcon: Icons.account_balance_rounded,
                  isRequired: true,
                  controller: controller,
                  focusNode: focusNode,
                  errorText: instError,
                  onChanged: (v) => context
                      .read<CvBloc>()
                      .add(CvUpdateEducation(widget.index, 'institution', v)),
                  onFieldSubmitted: (_) => onFieldSubmitted(),
                );
              },
            ),

            // 5. Major / Group / Field of Study
            CvTextField(
              label: 'Group / Major / Field of Study',
              hint: 'e.g. Science, Commerce, Computer Science',
              prefixIcon: Icons.auto_stories_outlined,
              controller: _fieldController,
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateEducation(widget.index, 'fieldOfStudy', v)),
            ),
          ],
        );
      },
    );
  }
}

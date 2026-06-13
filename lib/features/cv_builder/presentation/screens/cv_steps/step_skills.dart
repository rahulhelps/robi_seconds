import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';

class StepSkills extends StatelessWidget {
  final VoidCallback onNext;
  const StepSkills({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final skillList = state.model.skills;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CvStepHeader(
                    title: 'Skills',
                    subtitle:
                        'Group your skills by category. Separate individual skills with commas.',
                  ),
                  ...List.generate(skillList.length, (i) {
                    return _SkillCard(index: i);
                  }),
                  const SizedBox(height: 16),
                  CvAddButton(
                    label: 'Add Skill Category',
                    onTap: () => context
                        .read<CvBloc>()
                        .add(CvAddSkillCategory()),
                  ),
                  const SizedBox(height: 32),
                  CvNextButton(onNext: onNext),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkillCard extends StatelessWidget {
  final int index;
  const _SkillCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final skill = state.model.skills[index];
        return CvEntryCard(
          index: index,
          title: 'Skill Category #${index + 1}',
          onRemove: () =>
              context.read<CvBloc>().add(CvRemoveSkillCategory(index)),
          fields: [
            CvTextField(
              label: 'Category',
              hint: 'e.g. Programming Languages',
              errorText: state.showErrors && skill.category.trim().isEmpty
                  ? 'Required'
                  : null,
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateSkillCategory(index, 'category', v)),
            ),
            CvTextField(
              label: 'Skills (comma-separated)',
              hint: 'e.g. Dart, Flutter, Python',
              errorText: state.showErrors && skill.skills.isEmpty
                  ? 'At least one skill required'
                  : null,
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateSkillCategory(index, 'skills', v)),
            ),
          ],
        );
      },
    );
  }
}


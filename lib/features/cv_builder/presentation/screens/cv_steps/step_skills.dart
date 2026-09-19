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
                  const CvStepHeader(
                    title: 'Key Skills',
                    subtitle:
                        'Group your core technical & interpersonal skills by category. Separate skills with commas.',
                    icon: Icons.psychology_rounded,
                  ),
                  if (skillList.isEmpty) ...[
                    // If none added, auto-dispatch or show helper
                    Builder(builder: (ctx) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ctx.read<CvBloc>().add(const CvAddSkillCategory());
                      });
                      return const SizedBox.shrink();
                    }),
                  ],
                  ...List.generate(skillList.length, (i) {
                    return _SkillCard(index: i);
                  }),
                  const SizedBox(height: 12),
                  CvAddButton(
                    label: 'Add Skill Category',
                    onTap: () => context
                        .read<CvBloc>()
                        .add(const CvAddSkillCategory()),
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
        final showErrors = state.showErrors;

        return CvEntryCard(
          index: index,
          title: skill.category.isNotEmpty
              ? skill.category
              : 'Skill Category #${index + 1}',
          icon: Icons.lightbulb_outline_rounded,
          onRemove: () =>
              context.read<CvBloc>().add(CvRemoveSkillCategory(index)),
          fields: [
            CvTextField(
              label: 'Category Name',
              hint: 'e.g. Technical Skills, Leadership, Tools',
              prefixIcon: Icons.folder_open_rounded,
              isRequired: true,
              controller: TextEditingController(text: skill.category)
                ..selection =
                    TextSelection.collapsed(offset: skill.category.length),
              errorText: showErrors && skill.category.trim().isEmpty
                  ? 'Category name is required'
                  : null,
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateSkillCategory(index, 'category', v)),
            ),
            CvTextField(
              label: 'Skills (comma-separated)',
              hint: 'e.g. Flutter, Dart, REST API, Git, Docker',
              prefixIcon: Icons.stars_rounded,
              isRequired: true,
              controller: TextEditingController(text: skill.skills.join(', '))
                ..selection = TextSelection.collapsed(
                    offset: skill.skills.join(', ').length),
              errorText: showErrors && skill.skills.isEmpty
                  ? 'At least one skill item is required'
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';

class StepWorkExperience extends StatelessWidget {
  final VoidCallback onNext;
  const StepWorkExperience({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final expList = state.model.workExperience;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CvStepHeader(
                    title: 'Work Experience',
                    subtitle:
                        'Highlight your professional background, past roles, responsibilities, and achievements.',
                    icon: Icons.work_history_rounded,
                  ),
                  ...List.generate(expList.length, (i) {
                    return _ExperienceCard(index: i);
                  }),
                  const SizedBox(height: 12),
                  CvAddButton(
                    label: 'Add Work Experience',
                    onTap: () =>
                        context.read<CvBloc>().add(const CvAddExperience()),
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

class _ExperienceCard extends StatelessWidget {
  final int index;
  const _ExperienceCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final exp = state.model.workExperience[index];

        return CvEntryCard(
          index: index,
          title: exp.company.isNotEmpty
              ? '${exp.company}${exp.position.isNotEmpty ? " • ${exp.position}" : ""}'
              : 'Experience #${index + 1}',
          icon: Icons.business_center_outlined,
          onRemove: () =>
              context.read<CvBloc>().add(CvRemoveExperience(index)),
          fields: [
            CvTextField(
              label: 'Company / Organization',
              hint: 'e.g. Grameenphone, Brain Station 23, Google',
              prefixIcon: Icons.business_outlined,
              controller: TextEditingController(text: exp.company)
                ..selection =
                    TextSelection.collapsed(offset: exp.company.length),
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateExperience(index, 'company', v)),
            ),
            CvTextField(
              label: 'Designation / Position',
              hint: 'e.g. Senior Software Engineer',
              prefixIcon: Icons.badge_outlined,
              controller: TextEditingController(text: exp.position)
                ..selection =
                    TextSelection.collapsed(offset: exp.position.length),
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateExperience(index, 'position', v)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CvTextField(
                    label: 'Start Date',
                    hint: 'e.g. Jan 2021',
                    prefixIcon: Icons.calendar_today_rounded,
                    controller: TextEditingController(text: exp.startDate)
                      ..selection =
                          TextSelection.collapsed(offset: exp.startDate.length),
                    onChanged: (v) => context
                        .read<CvBloc>()
                        .add(CvUpdateExperience(index, 'startDate', v)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CvTextField(
                    label: 'End Date',
                    hint: 'e.g. Present / Dec 2023',
                    prefixIcon: Icons.event_available_rounded,
                    controller: TextEditingController(text: exp.endDate)
                      ..selection =
                          TextSelection.collapsed(offset: exp.endDate.length),
                    onChanged: (v) => context
                        .read<CvBloc>()
                        .add(CvUpdateExperience(index, 'endDate', v)),
                  ),
                ),
              ],
            ),
            CvTextField(
              label: 'Role Description',
              hint: 'Brief summary of your primary responsibilities...',
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
              controller: TextEditingController(text: exp.description)
                ..selection =
                    TextSelection.collapsed(offset: exp.description.length),
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateExperience(index, 'description', v)),
            ),
            CvTextField(
              label: 'Key Achievements (one per line)',
              hint: '• Led a team of 5 engineers\n• Reduced API response time by 45%',
              prefixIcon: Icons.emoji_events_outlined,
              maxLines: 4,
              controller: TextEditingController(text: exp.bullets.join('\n'))
                ..selection = TextSelection.collapsed(
                    offset: exp.bullets.join('\n').length),
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateExperience(index, 'bullets', v)),
            ),
          ],
        );
      },
    );
  }
}

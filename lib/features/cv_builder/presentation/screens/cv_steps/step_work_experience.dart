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
                  CvStepHeader(
                    title: 'Work Experience',
                    subtitle: 'List your previous roles and achievements.',
                  ),
                  ...List.generate(expList.length, (i) {
                    return _ExperienceCard(index: i);
                  }),
                  const SizedBox(height: 16),
                  CvAddButton(
                    label: 'Add Experience',
                    onTap: () =>
                        context.read<CvBloc>().add(CvAddExperience()),
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
    return CvEntryCard(
      index: index,
      title: 'Experience #${index + 1}',
      onRemove: () =>
          context.read<CvBloc>().add(CvRemoveExperience(index)),
      fields: [
        CvTextField(
          label: 'Company',
          hint: 'e.g. Google LLC',
          onChanged: (v) => context
              .read<CvBloc>()
              .add(CvUpdateExperience(index, 'company', v)),
        ),
        CvTextField(
          label: 'Position',
          hint: 'e.g. Software Engineer',
          onChanged: (v) => context
              .read<CvBloc>()
              .add(CvUpdateExperience(index, 'position', v)),
        ),
        Row(
          children: [
            Expanded(
              child: CvTextField(
                label: 'Start Date',
                hint: 'e.g. Jan 2021',
                onChanged: (v) => context
                    .read<CvBloc>()
                    .add(CvUpdateExperience(index, 'startDate', v)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CvTextField(
                label: 'End Date',
                hint: 'Present',
                onChanged: (v) => context
                    .read<CvBloc>()
                    .add(CvUpdateExperience(index, 'endDate', v)),
              ),
            ),
          ],
        ),
        CvTextField(
          label: 'Description',
          hint: 'Brief role description…',
          maxLines: 3,
          onChanged: (v) => context
              .read<CvBloc>()
              .add(CvUpdateExperience(index, 'description', v)),
        ),
        CvTextField(
          label: 'Key Achievements (one per line)',
          hint: 'e.g. Reduced load time by 40%',
          maxLines: 4,
          onChanged: (v) => context
              .read<CvBloc>()
              .add(CvUpdateExperience(index, 'bullets', v)),
        ),
      ],
    );
  }
}


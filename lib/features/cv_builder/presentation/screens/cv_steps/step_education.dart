import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';

class StepEducation extends StatelessWidget {
  final VoidCallback onNext;
  const StepEducation({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
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
                  CvStepHeader(
                    title: 'Education',
                    subtitle: 'Add your academic qualifications.',
                  ),
                  ...List.generate(educationList.length, (i) {
                    return _EducationCard(index: i);
                  }),
                  const SizedBox(height: 16),
                  CvAddButton(
                    label: 'Add Education',
                    onTap: () =>
                        context.read<CvBloc>().add(CvAddEducation()),
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

class _EducationCard extends StatelessWidget {
  final int index;
  const _EducationCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final edu = state.model.education[index];
        return CvEntryCard(
          index: index,
          title: 'Education #${index + 1}',
          onRemove: () => context.read<CvBloc>().add(CvRemoveEducation(index)),
          fields: [
            CvTextField(
              label: 'Institution',
              hint: 'e.g. Dhaka University',
              errorText: state.showErrors && edu.institution.trim().isEmpty
                  ? 'Required'
                  : null,
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateEducation(index, 'institution', v)),
            ),
            CvTextField(
              label: 'Degree',
              hint: 'e.g. Bachelor of Science',
              errorText: state.showErrors && edu.degree.trim().isEmpty
                  ? 'Required'
                  : null,
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateEducation(index, 'degree', v)),
            ),
            CvTextField(
              label: 'Field of Study',
              hint: 'e.g. Computer Science',
              onChanged: (v) => context
                  .read<CvBloc>()
                  .add(CvUpdateEducation(index, 'fieldOfStudy', v)),
            ),
            Row(
              children: [
                Expanded(
                  child: CvTextField(
                    label: 'Start Date',
                    hint: 'e.g. 2018',
                    onChanged: (v) => context
                        .read<CvBloc>()
                        .add(CvUpdateEducation(index, 'startDate', v)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CvTextField(
                    label: 'End Date',
                    hint: 'e.g. 2022',
                    onChanged: (v) => context
                        .read<CvBloc>()
                        .add(CvUpdateEducation(index, 'endDate', v)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';

/// The 6 proficiency values accepted by the backend enum.
/// DO NOT change these — they are enforced server-side.
const _proficiencyOptions = [
  'Beginner',
  'Elementary',
  'Intermediate',
  'Upper-Intermediate',
  'Advanced',
  'Native',
];

class StepLanguages extends StatelessWidget {
  final VoidCallback onNext;
  const StepLanguages({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final langList = state.model.languages;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CvStepHeader(
                    title: 'Languages',
                    subtitle: 'List languages you speak and your proficiency level.',
                  ),
                  ...List.generate(langList.length, (i) {
                    return _LanguageCard(
                      index: i,
                      currentProficiency: langList[i].proficiency,
                    );
                  }),
                  const SizedBox(height: 16),
                  CvAddButton(
                    label: 'Add Language',
                    onTap: () =>
                        context.read<CvBloc>().add(CvAddLanguage()),
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

class _LanguageCard extends StatelessWidget {
  final int index;
  final String currentProficiency;

  const _LanguageCard({
    required this.index,
    required this.currentProficiency,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the current value is always a valid option (fallback to first)
    final safeValue = _proficiencyOptions.contains(currentProficiency)
        ? currentProficiency
        : _proficiencyOptions.first;

    return CvEntryCard(
      index: index,
      title: 'Language #${index + 1}',
      onRemove: () =>
          context.read<CvBloc>().add(CvRemoveLanguage(index)),
      fields: [
        // Language name — free text is fine here
        CvTextField(
          label: 'Language',
          hint: 'e.g. English',
          onChanged: (v) => context
              .read<CvBloc>()
              .add(CvUpdateLanguage(index, 'language', v)),
        ),
        // Proficiency — MUST be a dropdown to match backend enum
        CvDropdownField(
          label: 'Proficiency',
          value: safeValue,
          options: _proficiencyOptions,
          onChanged: (v) {
            if (v != null) {
              context
                  .read<CvBloc>()
                  .add(CvUpdateLanguage(index, 'proficiency', v));
            }
          },
        ),
      ],
    );
  }
}


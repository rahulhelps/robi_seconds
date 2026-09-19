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
                  const CvStepHeader(
                    title: 'Languages',
                    subtitle:
                        'List the languages you speak, write, or understand and your proficiency level.',
                    icon: Icons.translate_rounded,
                  ),
                  if (langList.isEmpty) ...[
                    Builder(builder: (ctx) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ctx.read<CvBloc>().add(const CvAddLanguage());
                      });
                      return const SizedBox.shrink();
                    }),
                  ],
                  ...List.generate(langList.length, (i) {
                    return _LanguageCard(
                      index: i,
                      language: langList[i].language,
                      currentProficiency: langList[i].proficiency,
                    );
                  }),
                  const SizedBox(height: 12),
                  CvAddButton(
                    label: 'Add Another Language',
                    onTap: () =>
                        context.read<CvBloc>().add(const CvAddLanguage()),
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
  final String language;
  final String currentProficiency;

  const _LanguageCard({
    required this.index,
    required this.language,
    required this.currentProficiency,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = _proficiencyOptions.contains(currentProficiency)
        ? currentProficiency
        : _proficiencyOptions.first;

    return CvEntryCard(
      index: index,
      title: language.isNotEmpty
          ? '$language ($safeValue)'
          : 'Language #${index + 1}',
      icon: Icons.language_rounded,
      onRemove: () => context.read<CvBloc>().add(CvRemoveLanguage(index)),
      fields: [
        CvTextField(
          label: 'Language Name',
          hint: 'e.g. English, Bengali, Hindi, Arabic',
          prefixIcon: Icons.language_rounded,
          controller: TextEditingController(text: language)
            ..selection = TextSelection.collapsed(offset: language.length),
          onChanged: (v) => context
              .read<CvBloc>()
              .add(CvUpdateLanguage(index, 'language', v)),
        ),
        CvDropdownField(
          label: 'Proficiency Level',
          value: safeValue,
          options: _proficiencyOptions,
          prefixIcon: Icons.trending_up_rounded,
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

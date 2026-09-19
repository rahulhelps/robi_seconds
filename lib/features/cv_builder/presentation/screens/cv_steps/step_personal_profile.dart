import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';
import '../../../domain/cv_validators.dart';

/// Backend-enforced enum values for marital status.
const _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];

/// Backend-enforced enum values for gender.
const _genderOptions = ['Male', 'Female', 'Other'];

class StepPersonalProfile extends StatelessWidget {
  final VoidCallback onNext;
  const StepPersonalProfile({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvBloc, CvState>(
      builder: (context, state) {
        final p = state.model.personalProfile;
        final pi = state.model.personalInfo;
        final showErrors = state.showErrors;

        final safeMarital = _maritalOptions.contains(p.maritalStatus)
            ? p.maritalStatus
            : _maritalOptions.first;
        final safeGender = _genderOptions.contains(p.gender)
            ? p.gender
            : _genderOptions.first;

        final emailError = showErrors
            ? (pi.email.trim().isEmpty
                ? 'Email is required'
                : !EmailValidator.validate(pi.email.trim())
                    ? 'Invalid email format'
                    : null)
            : null;

        final phoneError = showErrors
            ? (pi.phone.trim().isEmpty
                ? 'Phone number is required'
                : !CvValidators.isValidPhone(pi.phone.trim())
                    ? 'Invalid phone number (7-15 digits)'
                    : null)
            : null;

        final nameError = showErrors && pi.name.trim().isEmpty
            ? 'Full name is required'
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CvStepHeader(
                    title: 'Personal Profile',
                    subtitle: 'Fill in your basic information and background details.',
                    icon: Icons.person_rounded,
                  ),

                  // Section 1: Basic Information
                  _SectionCard(
                    title: 'Basic Information',
                    icon: Icons.badge_outlined,
                    children: [
                      _PersonalInfoField(
                        label: 'Full Name',
                        field: 'name',
                        hint: 'e.g. Mohammad Rahim',
                        prefixIcon: Icons.person_outline_rounded,
                        isRequired: true,
                        errorText: nameError,
                      ),
                      _PersonalInfoField(
                        label: 'Email',
                        field: 'email',
                        hint: 'e.g. rahim@example.com',
                        prefixIcon: Icons.email_outlined,
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                        errorText: emailError,
                      ),
                      _PersonalInfoField(
                        label: 'Phone Number',
                        field: 'phone',
                        hint: 'e.g. 01712345678',
                        prefixIcon: Icons.phone_outlined,
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        errorText: phoneError,
                      ),
                      _PersonalInfoField(
                        label: 'Present Address',
                        field: 'address',
                        hint: 'e.g. House 12, Road 5, Dhanmondi, Dhaka',
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Additional Details
                  _SectionCard(
                    title: 'Additional Details',
                    icon: Icons.info_outline_rounded,
                    children: [
                      _ProfileField(
                        label: "Father's Name",
                        field: 'fatherName',
                        hint: "e.g. Abdul Karim",
                        prefixIcon: Icons.family_restroom_outlined,
                      ),
                      CvDatePickerField(
                        label: 'Date of Birth',
                        value: p.dateOfBirth,
                        hint: 'Select your date of birth',
                        onDateSelected: (v) => context
                            .read<CvBloc>()
                            .add(CvUpdatePersonalProfile('dateOfBirth', v)),
                      ),
                      _ProfileField(
                        label: 'Nationality',
                        field: 'nationality',
                        hint: 'e.g. Bangladeshi',
                        prefixIcon: Icons.flag_outlined,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CvDropdownField(
                              label: 'Marital Status',
                              value: safeMarital,
                              options: _maritalOptions,
                              prefixIcon: Icons.favorite_outline_rounded,
                              onChanged: (v) {
                                if (v != null) {
                                  context.read<CvBloc>().add(
                                        CvUpdatePersonalProfile(
                                            'maritalStatus', v),
                                      );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CvDropdownField(
                              label: 'Gender',
                              value: safeGender,
                              options: _genderOptions,
                              prefixIcon: Icons.wc_rounded,
                              onChanged: (v) {
                                if (v != null) {
                                  context.read<CvBloc>().add(
                                        CvUpdatePersonalProfile('gender', v),
                                      );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      _ProfileField(
                        label: 'Key Strengths',
                        field: 'strength',
                        hint: 'e.g. Leadership, Team Management, Problem Solving',
                        prefixIcon: Icons.fitness_center_rounded,
                        maxLines: 2,
                      ),
                      _ProfileField(
                        label: 'Hobbies & Interests',
                        field: 'hobbies',
                        hint: 'e.g. Reading, Traveling, Tech Innovations',
                        prefixIcon: Icons.palette_outlined,
                        maxLines: 2,
                      ),
                    ],
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF024D87).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: const Color(0xFF024D87)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String field;
  final String? hint;
  final int maxLines;
  final IconData? prefixIcon;

  const _ProfileField({
    required this.label,
    required this.field,
    this.hint,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CvTextField(
      label: label,
      hint: hint ?? 'Enter $label',
      maxLines: maxLines,
      prefixIcon: prefixIcon,
      onChanged: (v) =>
          context.read<CvBloc>().add(CvUpdatePersonalProfile(field, v)),
    );
  }
}

class _PersonalInfoField extends StatelessWidget {
  final String label;
  final String field;
  final String? hint;
  final int maxLines;
  final String? errorText;
  final IconData? prefixIcon;
  final bool isRequired;
  final TextInputType? keyboardType;

  const _PersonalInfoField({
    required this.label,
    required this.field,
    this.hint,
    this.maxLines = 1,
    this.errorText,
    this.prefixIcon,
    this.isRequired = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return CvTextField(
      label: label,
      hint: hint ?? 'Enter $label',
      maxLines: maxLines,
      errorText: errorText,
      prefixIcon: prefixIcon,
      isRequired: isRequired,
      keyboardType: keyboardType,
      onChanged: (v) =>
          context.read<CvBloc>().add(CvUpdatePersonalInfo(field, v)),
    );
  }
}

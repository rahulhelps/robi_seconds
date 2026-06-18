import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '../../bloc/cv_bloc.dart';
import '../../../../../core/widgets/cv_form_widgets.dart';

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

        // Safe dropdown values — fallback to first option if not yet set
        final safeMarital = _maritalOptions.contains(p.maritalStatus)
            ? p.maritalStatus
            : _maritalOptions.first;
        final safeGender = _genderOptions.contains(p.gender)
            ? p.gender
            : _genderOptions.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Profile',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add details that bring your personality to life on the CV.',
                    style: GoogleFonts.inter(
                        fontSize: 15, color: const Color(0xFF3E4A3C)),
                  ),
                  const SizedBox(height: 32),

                  // Basic Profile Info (Required)
                  Text(
                    'Basic Information',
                    style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF191C1D)),
                  ),
                  const SizedBox(height: 16),
                  _PersonalInfoField(
                    label: 'Full Name',
                    field: 'name',
                    errorText: state.showErrors && state.model.personalInfo.name.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _PersonalInfoField(
                    label: 'Email',
                    field: 'email',
                    hint: 'e.g. name@nittotech.com',
                    errorText: state.showErrors
                        ? (state.model.personalInfo.email.trim().isEmpty
                            ? 'Required'
                            : !EmailValidator.validate(
                                    state.model.personalInfo.email.trim())
                                ? 'Invalid email format'
                                : null)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _PersonalInfoField(
                    label: 'Phone Number',
                    field: 'phone',
                    hint: 'e.g. +880 17...',
                    errorText: state.showErrors && state.model.personalInfo.phone.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _PersonalInfoField(label: 'Address', field: 'address', maxLines: 2),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  Text(
                    'Additional Details',
                    style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF191C1D)),
                  ),
                  const SizedBox(height: 16),

                  // Free-text fields
                  _ProfileField(label: "Father's Name", field: 'fatherName'),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Date of Birth',
                    field: 'dateOfBirth',
                    hint: 'e.g. 01 Jan 1995',
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Nationality',
                    field: 'nationality',
                    hint: 'e.g. Bangladeshi',
                  ),
                  const SizedBox(height: 16),

                  // Dropdowns for enum fields
                  CvDropdownField(
                    label: 'Marital Status',
                    value: safeMarital,
                    options: _maritalOptions,
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<CvBloc>()
                            .add(CvUpdatePersonalProfile('maritalStatus', v));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CvDropdownField(
                    label: 'Gender',
                    value: safeGender,
                    options: _genderOptions,
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<CvBloc>()
                            .add(CvUpdatePersonalProfile('gender', v));
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Free-text fields continued
                  _ProfileField(
                    label: 'Strength',
                    field: 'strength',
                    hint: 'e.g. Leadership, Problem-solving',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Hobbies',
                    field: 'hobbies',
                    hint: 'e.g. Reading, Photography',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF024D87),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String field;
  final String? hint;
  final int maxLines;

  const _ProfileField({
    required this.label,
    required this.field,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CvTextField(
      label: label,
      hint: hint ?? 'Enter $label',
      maxLines: maxLines,
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

  const _PersonalInfoField({
    required this.label,
    required this.field,
    this.hint,
    this.maxLines = 1,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CvTextField(
      label: label,
      hint: hint ?? 'Enter $label',
      maxLines: maxLines,
      errorText: errorText,
      onChanged: (v) =>
          context.read<CvBloc>().add(CvUpdatePersonalInfo(field, v)),
    );
  }
}


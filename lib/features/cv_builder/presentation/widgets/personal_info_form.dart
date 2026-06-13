import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/personal_info/personal_info_bloc.dart';

class PersonalInfoForm extends StatelessWidget {
  const PersonalInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF024D87).withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isWide ? 1 : 0,
                  child: const _FormField(
                    label: 'Full Name',
                    hintText: 'e.g. Julian Montgomery',
                    fieldKey: 'fullName',
                  ),
                ),
                if (isWide) const SizedBox(width: 24),
                if (!isWide) const SizedBox(height: 24),
                Expanded(
                  flex: isWide ? 1 : 0,
                  child: const _FormField(
                    label: 'Job Title',
                    hintText: 'e.g. Senior Brand Designer',
                    fieldKey: 'jobTitle',
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isWide ? 1 : 0,
                  child: const _FormField(
                    label: 'Email Address',
                    hintText: 'julian@nittotech.com',
                    fieldKey: 'email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                if (isWide) const SizedBox(width: 24),
                if (!isWide) const SizedBox(height: 24),
                Expanded(
                  flex: isWide ? 1 : 0,
                  child: const _FormField(
                    label: 'Phone Number',
                    hintText: '+1 (555) 000-0000',
                    fieldKey: 'phone',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          const _FormField(
            label: 'Location',
            hintText: 'London, United Kingdom',
            fieldKey: 'location',
          ),
          const SizedBox(height: 24),
          const _FormField(
            label: 'Professional Bio',
            hintText: 'Briefly describe your career narrative...',
            fieldKey: 'bio',
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hintText;
  final String fieldKey;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.hintText,
    required this.fieldKey,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: const Color(0xFF3E4A3C),
            ),
          ),
        ),
        TextFormField(
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: const Color(0xFF191C1D),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF3F4F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF024D87), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            context
                .read<PersonalInfoBloc>()
                .add(PersonalInfoFieldChanged(fieldKey, value));
          },
        ),
      ],
    );
  }
}

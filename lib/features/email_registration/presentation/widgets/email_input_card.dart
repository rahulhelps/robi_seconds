import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Email input card with a label, leading mail icon, and text field.
/// Mirrors the HTML "Input Card" section.
/// Supports [errorText] for inline validation feedback and [onChanged] for BLoC events.
class EmailInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const EmailInputCard({
    super.key,
    required this.controller,
    this.hintText,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EMAIL REGISTRATION',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: const Color(0xFF6E7B6B),
            ),
          ),
          const SizedBox(height: 14),
          // Input field with mail icon prefix
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFBA1A1A)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.mail_rounded,
                    color: hasError
                        ? const Color(0xFFBA1A1A)
                        : const Color(0xFF024D87),
                    size: 22,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF191C1D),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText ?? 'Enter your email address (optional)',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0x80BFC9BF),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          // Inline error text — only shown when hasError is true
          if (hasError) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFBA1A1A),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFBA1A1A),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

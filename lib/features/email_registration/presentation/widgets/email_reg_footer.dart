import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Security footer shown at the bottom of the Email Registration screen.
class EmailRegFooter extends StatelessWidget {
  const EmailRegFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: Color(0xFF6E7B6B),
            ),
            const SizedBox(width: 6),
            Text(
              'SECURE ENCRYPTION ENABLED',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: const Color(0xFF6E7B6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Your email is safe with us. We never share your data.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0x996E7B6B),
          ),
        ),
      ],
    );
  }
}

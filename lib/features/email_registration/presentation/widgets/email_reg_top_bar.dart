import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top app bar for the Email Registration screen.
/// Shows a back button, the app brand title, and a "Skip" action.
class EmailRegTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSkip;

  const EmailRegTopBar({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: const Color(0x14006E25),
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: SizedBox(),
      // IconButton(
      //   icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF024D87)),
      //   onPressed: () => Navigator.maybePop(context),
      // ),
      title: Text(
        'QuickCV Pro',
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: const Color(0xFF024D87),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6E7B6B),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Skip',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

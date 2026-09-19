import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CustomGradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback? onBackPressed;
  final bool disableTopPadding;
  final bool showBackButton;
  final Widget? trailing;

  const CustomGradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    this.onBackPressed,
    this.disableTopPadding = false,
    this.showBackButton = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = disableTopPadding ? 0.0 : MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(4, topPadding + 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              else
                const SizedBox(width: 16, height: 48),
              const Spacer(),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

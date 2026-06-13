import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_colors.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: ProfileColors.outline, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ProfileColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ProfileColors.outline.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

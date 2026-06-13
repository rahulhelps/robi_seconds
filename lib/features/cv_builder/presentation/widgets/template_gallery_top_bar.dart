import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplateGalleryTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TemplateGalleryTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= 768; // md breakpoint in HTML

    return ClipRect(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Icon(
                    Icons.description,
                    color: Color(0xFF024D87),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'QuickCV',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF191C1D),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Desktop nav or mobile menu
              if (isWide) ...[
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: _NavText('Home', false),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF024D87),
                            width: 2,
                          ),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: _NavText('Services', true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {},
                      child: _NavText('My CVs', false),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.menu, color: Color(0xFF71717A)),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavText extends StatelessWidget {
  final String text;
  final bool isActive;

  const _NavText(this.text, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        color: isActive ? const Color(0xFF024D87) : const Color(0xFF71717A),
      ),
    );
  }
}

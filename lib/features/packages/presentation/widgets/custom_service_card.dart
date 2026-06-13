import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomServiceCard extends StatelessWidget {
  const CustomServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEEF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need something bespoke?',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our career consultants are available for hourly strategy sessions and custom documentation needs.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF3E4A3C),
                ),
              ),
            ],
          );

          final buttonRow = Row(
            mainAxisAlignment:
                isWide ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isWide)
                Expanded(child: _buildChatButton())
              else
                _buildChatButton(),
              const SizedBox(width: 16),
              if (!isWide)
                Expanded(child: _buildMenuButton())
              else
                _buildMenuButton(),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 32),
                buttonRow,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textBlock,
              const SizedBox(height: 24),
              buttonRow,
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.04),
      ).copyWith(backgroundColor: WidgetStateProperty.all(Colors.transparent)),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFBFC9BF), Color(0xFFD9DADB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6E7B6B).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          alignment: Alignment.center,
          child: Text(
            'Chat Now',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191C1D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'View Menu',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF024D87),
        ),
      ),
    );
  }
}

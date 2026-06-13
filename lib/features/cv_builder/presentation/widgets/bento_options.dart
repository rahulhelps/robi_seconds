import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BentoOptions extends StatelessWidget {
  const BentoOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              flex: isWide ? 1 : 0,
              child: const _BentoCard(
                icon: Icons.biotech,
                iconColor: Color(0xFF024D87),
                title: 'Research section',
                subtitle: 'Include publications or studies.',
                actionWidget: _ToggleSwitchAction(),
              ),
            ),
            if (isWide) const SizedBox(width: 24),
            if (!isWide) const SizedBox(height: 24),
            Expanded(
              flex: isWide ? 1 : 0,
              child: const _BentoCard(
                icon: Icons.language,
                iconColor: Color(0xFF51B1E1),
                title: 'Portfolio Link',
                subtitle: 'Add your digital showcase.',
                actionWidget: Icon(
                  Icons.add_circle,
                  color: Color(0xFFBDCAB9),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget actionWidget;

  const _BentoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFE1E3E4),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF3E4A3C),
                      ),
                    ),
                  ],
                ),
              ),
              actionWidget,
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitchAction extends StatelessWidget {
  const _ToggleSwitchAction();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFE1E3E4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.centerLeft,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

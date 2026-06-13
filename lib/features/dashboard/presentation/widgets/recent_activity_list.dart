import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _ActivityItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String message;
  final String boldPart; // text to bold inside message
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.message,
    required this.boldPart,
    required this.time,
  });
}

const _activities = [
  _ActivityItem(
    icon: Icons.edit_note,
    iconColor: Color(0xFF024D87),
    iconBg: Color(0xFFE8F5E9),
    message: "You edited CV 'Marketing Manager'",
    boldPart: 'Marketing Manager',
    time: '2h ago',
  ),
  _ActivityItem(
    icon: Icons.group_outlined,
    iconColor: Color(0xFF1565C0),
    iconBg: Color(0xFFE3F2FD),
    message: "Your profile was viewed by 'Google Recruiters'",
    boldPart: 'Google Recruiters',
    time: '5h ago',
  ),
  _ActivityItem(
    icon: Icons.cloud_download_outlined,
    iconColor: Color(0xFFE65100),
    iconBg: Color(0xFFFFF3E0),
    message: "CV 'Marketing Manager' was downloaded by 'Innovate Tech'",
    boldPart: 'Innovate Tech',
    time: '1d ago',
  ),
];

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191C1D),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'SEE ALL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF024D87),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Activity card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _activities
                .map((a) => _ActivityTile(item: a))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HighlightedText(
                  message: item.message,
                  boldPart: item.boldPart,
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6E7B6B),
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

/// Renders a message with one bold span highlighted inside it.
class _HighlightedText extends StatelessWidget {
  final String message;
  final String boldPart;

  const _HighlightedText({required this.message, required this.boldPart});

  @override
  Widget build(BuildContext context) {
    final idx = message.indexOf(boldPart);
    if (idx == -1) {
      return Text(message,
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF191C1D)));
    }

    final before = message.substring(0, idx);
    final after = message.substring(idx + boldPart.length);

    final base = GoogleFonts.inter(fontSize: 13, color: const Color(0xFF191C1D));

    return RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: boldPart,
            style: base.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

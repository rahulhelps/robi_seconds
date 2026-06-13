import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedInternetBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRetry;
  final bool compact;

  const AnimatedInternetBanner({
    super.key,
    required this.isOffline,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      alignment: Alignment.topCenter,
      child: isOffline
          ? NoInternetWidget(onRetry: onRetry, compact: compact)
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool compact;

  const NoInternetWidget({
    super.key,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red[50],
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 8 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_connected_no_internet_4_rounded,
            color: Colors.red[700],
            size: compact ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No Internet Connection',
              style: GoogleFonts.inter(
                color: Colors.red[900],
                fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
                fontSize: compact ? 13 : 14,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 16, color: Colors.red[800]),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}

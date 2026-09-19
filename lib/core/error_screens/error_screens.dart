import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorScreen extends StatelessWidget {
  final int statusCode;
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;

  const ErrorScreen({
    super.key,
    required this.statusCode,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  statusCode.toString(),
                  style: GoogleFonts.manrope(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: const Color(0xFF8A939B),
                  ),
                ),
                const SizedBox(height: 32),
                if (primaryActionLabel != null && onPrimaryAction != null)
                  ElevatedButton(
                    onPressed: onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF024D87),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(primaryActionLabel!),
                  ),
                if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onSecondaryAction,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF024D87),
                      textStyle: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(secondaryActionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForbiddenScreen extends StatelessWidget {
  final VoidCallback? onGoBack;
  final VoidCallback? onGoHome;

  const ForbiddenScreen({super.key, this.onGoBack, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      statusCode: 403,
      title: 'Access Denied',
      message: 'You don’t have permission to access this resource. If you believe this is an error, please contact support.',
      icon: Icons.lock_rounded,
      iconColor: const Color(0xFFEF4444),
      iconBackgroundColor: const Color(0xFFFEF2F2),
      primaryActionLabel: onGoBack != null ? 'Go Back' : null,
      onPrimaryAction: onGoBack,
      secondaryActionLabel: 'Return Home',
      onSecondaryAction: onGoHome ?? () => Navigator.pushReplacementNamed(context, '/dashboard'),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  final VoidCallback? onGoBack;
  final VoidCallback? onGoHome;

  const NotFoundScreen({super.key, this.onGoBack, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      statusCode: 404,
      title: 'Page Not Found',
      message: 'The page you’re looking for doesn’t exist or has been moved. Let’s get you back on track.',
      icon: Icons.search_off_rounded,
      iconColor: const Color(0xFF024D87),
      iconBackgroundColor: const Color(0xFFEEF2FF),
      primaryActionLabel: onGoBack != null ? 'Go Back' : null,
      onPrimaryAction: onGoBack,
      secondaryActionLabel: 'Return Home',
      onSecondaryAction: onGoHome ?? () => Navigator.pushReplacementNamed(context, '/dashboard'),
    );
  }
}

class PageExpiredScreen extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onGoHome;

  const PageExpiredScreen({super.key, this.onRefresh, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      statusCode: 419,
      title: 'Page Expired',
      message: 'Your session has expired or the page is outdated. Please refresh or try again.',
      icon: Icons.hourglass_empty_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBackgroundColor: const Color(0xFFFFFBEB),
      primaryActionLabel: 'Refresh Page',
      onPrimaryAction: onRefresh ?? () => Navigator.pushReplacementNamed(context, '/dashboard'),
      secondaryActionLabel: 'Return Home',
      onSecondaryAction: onGoHome ?? () => Navigator.pushReplacementNamed(context, '/dashboard'),
    );
  }
}

class ServerErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ServerErrorScreen({super.key, this.onRetry, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      statusCode: 500,
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later or contact support if the issue persists.',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFEF4444),
      iconBackgroundColor: const Color(0xFFFEF2F2),
      primaryActionLabel: 'Try Again',
      onPrimaryAction: onRetry ?? () => Navigator.pushReplacementNamed(context, '/dashboard'),
      secondaryActionLabel: 'Return Home',
      onSecondaryAction: onGoHome ?? () => Navigator.pushReplacementNamed(context, '/dashboard'),
    );
  }
}

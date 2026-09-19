import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Shown when BDApps check_subscription returns INITIAL CHARGING PENDING.
/// Auto-retries every 5 seconds until the subscription becomes active or expired.
class SubscriptionPendingScreen extends StatefulWidget {
  const SubscriptionPendingScreen({super.key});

  @override
  State<SubscriptionPendingScreen> createState() =>
      _SubscriptionPendingScreenState();
}

class _SubscriptionPendingScreenState
    extends State<SubscriptionPendingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _retryCountdown = 5;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Start the 5-second countdown + retry loop.
    _startRetryLoop();
  }

  Future<void> _startRetryLoop() async {
    while (mounted) {
      for (int i = 5; i >= 1; i--) {
        if (!mounted) return;
        setState(() => _retryCountdown = i);
        await Future.delayed(const Duration(seconds: 1));
      }
      if (!mounted) return;
      // Dispatch subscription check. BlocListener handles the result.
      final phone = _getPhone(context);
      if (phone.isNotEmpty) {
        context.read<AuthBloc>().add(CheckSubscriptionStatus(phone));
      }
      // Wait a moment for the result before restarting countdown.
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String _getPhone(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['phone'] as String? ?? '';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = _getPhone(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/dashboard', (route) => false);
        } else if (state is AuthSubscriptionExpired) {
          Navigator.pushReplacementNamed(
            context,
            '/subscription_expired',
            arguments: {'phone': state.phone},
          );
        }
        // If still pending, the loop continues automatically.
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            // Background blobs
            Positioned(
              bottom: -96,
              right: -96,
              child: Container(
                width: 256,
                height: 256,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1A28A745),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x1A28A745),
                        blurRadius: 80,
                        spreadRadius: 40)
                  ],
                ),
              ),
            ),
            Positioned(
              top: -96,
              left: -96,
              child: Container(
                width: 256,
                height: 256,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1A024D87),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x1A024D87),
                        blurRadius: 80,
                        spreadRadius: 40)
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing ring animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, _) {
                          final t = _pulseController.value;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: (1 - t) * 0.3,
                                child: Transform.scale(
                                  scale: 0.7 + t * 0.6,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF024D87),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF024D87),
                                      Color(0xFF28A745),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF024D87)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.hourglass_top_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Processing Subscription',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF191C1D),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your subscription is being activated.\nThis may take a few moments…',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF3E4A3C),
                          height: 1.6,
                        ),
                      ),

                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            phone,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF024D87),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Countdown chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF4FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF024D87).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF024D87)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Retrying in $_retryCountdown s…',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF024D87),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Logout option
                      TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const LogoutRequested());
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/auth', (route) => false);
                        },
                        child: Text(
                          'Logout instead',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Powered by BDApps · Robi & Airtel',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

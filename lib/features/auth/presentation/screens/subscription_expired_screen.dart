import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Shown when BDApps check_subscription returns UNREGISTERED.
/// Allows the user to re-subscribe or logout.
class SubscriptionExpiredScreen extends StatelessWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final phone = args?['phone'] as String? ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          // OTP sent after re-subscribe tap – go to verification screen.
          Navigator.pushNamed(
            context,
            '/verification',
            arguments: {
              'referenceNo': state.referenceNo,
              'phone': state.phone,
            },
          );
        } else if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent),
          );
        }
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
            // Background decorative blobs
            Positioned(
              bottom: -96,
              right: -96,
              child: Container(
                width: 256,
                height: 256,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1AFF5555),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x1AFF5555),
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
                  color: Color(0x1AEE6189),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x1AEE6189),
                        blurRadius: 80,
                        spreadRadius: 40)
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFEBEB),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Subscription Expired',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF191C1D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          'Your Robi/Airtel daily subscription (2 BDT/day) is no longer active. Re-subscribe to continue using QuickCV Pro.',
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

                        // Re-subscribe button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return Opacity(
                              opacity: isLoading ? 0.6 : 1.0,
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF024D87),
                                      Color(0xFF28A745),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14006E25),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(9999),
                                    onTap: isLoading || phone.isEmpty
                                        ? null
                                        : () {
                                            context
                                                .read<AuthBloc>()
                                                .add(SendOtpRequested(phone));
                                          },
                                    child: Center(
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Re-subscribe',
                                              style: GoogleFonts.manrope(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const LogoutRequested());
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/auth',
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF024D87), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            child: Text(
                              'Logout',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF024D87),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Branding note
                        Text(
                          'Powered by BDApps · Robi & Airtel',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';
import '../bloc/payments_state.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_card.dart';
import 'package:quickcvpro/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickcvpro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quickcvpro/features/auth/presentation/bloc/auth_event.dart';
import 'package:quickcvpro/features/auth/presentation/bloc/auth_state.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentsBloc(),
      child: const _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthUnsubscribeSuccess) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/auth',
                          (route) => false,
                        );
                      } else if (state is AuthUnsubscribeFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      'Upgrade to Pro',
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.8,
                        color: const Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unlock premium editorial layouts and expert CV reviews.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: const Color(0xFF6E7B6B),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const OrderSummaryCard(),
                    const SizedBox(height: 32),

                    Text(
                      'SELECT PAYMENT METHOD',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF6E7B6B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    BlocBuilder<PaymentsBloc, PaymentsState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            PaymentMethodCard(
                              title: 'Robi DCB',
                              subtitle: '৳2/day with Robi carrier billing',
                              value: 'robi',
                              groupValue: state.selectedMethod,
                              onChanged: (val) => context.read<PaymentsBloc>().add(SelectPaymentMethod(val)),
                              iconBackgroundColor: const Color(0xFFE91E63).withValues(alpha: 0.1),
                              iconWidget: const Icon(
                                Icons.phone_android_rounded,
                                size: 24,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            const SizedBox(height: 12),
                            PaymentMethodCard(
                              title: 'Airtel / Cirkle DCB',
                              subtitle: '৳2/day with Airtel carrier billing',
                              value: 'airtel_cirkle',
                              groupValue: state.selectedMethod,
                              onChanged: (val) => context.read<PaymentsBloc>().add(SelectPaymentMethod(val)),
                              iconBackgroundColor: const Color(0xFFFF6F00).withValues(alpha: 0.1),
                              iconWidget: const Icon(
                                Icons.wifi_calling_rounded,
                                size: 24,
                                color: Color(0xFFFF6F00),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        final isSubscribed = profileState is ProfileLoaded && profileState.isSubscriptionActive;

                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isSubscribed) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'You already have premium',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: const Color(0xFF191C1D),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Opening carrier billing...'),
                                        backgroundColor: Color(0xFF024D87),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    context.read<PaymentsBloc>().add(const ConfirmPayment());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSubscribed ? Colors.grey[800] : const Color(0xFF024D87),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isSubscribed ? 'Already Paid' : 'Confirm Payment',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (isSubscribed) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () {
                                    final phone = profileState.phoneNumber;
                                    if (phone.isNotEmpty) {
                                      context.read<AuthBloc>().add(UnsubscribeRequested(phone));
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: Text(
                                    'Unsubscribe',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 18,
                          color: Color(0xFF3E4A3C),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure 256-bit SSL Encrypted Payment',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF3E4A3C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

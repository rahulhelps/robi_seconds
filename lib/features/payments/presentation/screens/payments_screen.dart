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
              constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
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

                  // Order Summary
                  const OrderSummaryCard(),
                  const SizedBox(height: 32),

                  // Payment Methods Section
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
                            title: 'bKash Checkout',
                            subtitle: 'Instant payment with wallet',
                            value: 'bkash',
                            groupValue: state.selectedMethod,
                            onChanged: (val) => context.read<PaymentsBloc>().add(SelectPaymentMethod(val)),
                            iconBackgroundColor: const Color(0xFFD12053).withValues(alpha: 0.1),
                            iconWidget: Image.asset(
                              'assets/images/bkash_logo.jpg',
                              fit: BoxFit.contain,
                              width: 32,
                              height: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PaymentMethodCard(
                            title: 'Nagad',
                            subtitle: 'Fast secure gateway',
                            value: 'nagad',
                            groupValue: state.selectedMethod,
                            onChanged: (val) => context.read<PaymentsBloc>().add(SelectPaymentMethod(val)),
                            iconBackgroundColor: const Color(0xFFF37021).withValues(alpha: 0.1),
                            iconWidget: Image.asset(
                              'assets/images/nagad_logo.jpg',
                              fit: BoxFit.contain,
                              width: 32,
                              height: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PaymentMethodCard(
                            title: 'Credit or Debit Card',
                            subtitle: 'Visa, Mastercard, AMEX',
                            value: 'card',
                            groupValue: state.selectedMethod,
                            onChanged: (val) => context.read<PaymentsBloc>().add(SelectPaymentMethod(val)),
                            iconBackgroundColor: const Color(0xFF024D87).withValues(alpha: 0.1),
                            iconWidget: const Icon(
                              Icons.credit_card,
                              size: 24,
                              color: Color(0xFF024D87),
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

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // ... logic same ...
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
                                SnackBar(
                                  content: Text(
                                    'SSLCommerz payment system coming soon',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: const Color(0xFF024D87),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      );
                    },
                  ),


                  const SizedBox(height: 16),
                  
                  // Security info
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
    );
  }
}

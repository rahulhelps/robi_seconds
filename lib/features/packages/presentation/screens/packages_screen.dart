import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcvpro/core/widgets/app_buttons.dart';
import 'package:quickcvpro/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quickcvpro/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickcvpro/features/payments/presentation/bloc/payment_bloc.dart';
import '../bloc/packages_bloc.dart';
import '../widgets/packages_hero_section.dart';
import '../widgets/stats_metric_widget.dart';
import 'package:google_fonts/google_fonts.dart';



class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PackagesServicesView();
  }
}

void _showPackagesSnackBar(BuildContext context, String message, {bool isError = true}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF191C1D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
    ),
  );
}

class _PackagesServicesView extends StatelessWidget {
  const _PackagesServicesView();

  @override
  Widget build(BuildContext context) {
    // No nested Scaffold: parent dashboard already provides a Scaffold + AppBar.
    return MultiBlocListener(
      listeners: [
        BlocListener<PackagesBloc, PackagesState>(
          listenWhen: (prev, curr) => curr is PackagesNavigateToPayments,
          listener: (context, state) {
            final nav = state as PackagesNavigateToPayments;
            try {
              context.read<DashboardBloc>().add(
                    DashboardNavigateToPayments(nav.summary),
                  );
              context.read<PackagesBloc>().add(
                    const PackagesCheckoutNavigationConsumed(),
                  );
            } catch (_) {
              context.read<PackagesBloc>().add(const PackagesCheckoutAborted());
              _showPackagesSnackBar(
                context,
                'Checkout is unavailable. Open the app from the home dashboard and try again.',
              );
            }
          },
        ),
        BlocListener<PackagesBloc, PackagesState>(
          listenWhen: (prev, curr) => curr is PackagesError,
          listener: (context, state) {
            _showPackagesSnackBar(
              context,
              (state as PackagesError).message,
            );
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          final isSubscribed = profileState is ProfileLoaded && profileState.isSubscriptionActive;

          return Material(
            color: const Color(0xFFF8F9FA),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PackagesHeroSection(),
                      const SizedBox(height: 48),
                      
                      // Single Premium Package Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF024D87).withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF024D87),
                                    const Color(0xFF024D87).withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'MOST POPULAR',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Premium Plan',
                                    style: GoogleFonts.manrope(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Unlimited access to all professional templates and AI generation.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  _PackageFeature(title: 'Unlimited CV Generations'),
                                  _PackageFeature(title: 'All Premium Templates'),
                                  _PackageFeature(title: 'AI Summary & Optimization'),
                                  _PackageFeature(title: 'Priority Support'),
                                  const SizedBox(height: 40),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Monthly billing',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: const Color(0xFF3E4A3C),
                                              ),
                                            ),
                                            BlocBuilder<PaymentBloc, PaymentState>(
                                              builder: (context, paymentState) {
                                                final priceText = paymentState is PaymentLoaded
                                                    ? paymentState.priceText
                                                    : '...';
                                                return Text(
                                                  priceText,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(0xFF191C1D),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        flex: 2,
                                        child: AppButton(
                                          label: isSubscribed ? 'Already Activated' : 'Select Package',
                                          isDisabled: isSubscribed,
                                          onTap: () {
                                            context.read<PackagesBloc>().add(
                                              const PackagesCheckoutStarted(
                                                planName: 'Premium Plan',
                                                price: 10.0,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      const StatsMetricWidget(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

  }
}
class _PackageFeature extends StatelessWidget {
  final String title;

  const _PackageFeature({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF024D87), size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF3E4A3C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

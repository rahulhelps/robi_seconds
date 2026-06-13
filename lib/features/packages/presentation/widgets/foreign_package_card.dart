import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/packages_bloc.dart';

class ForeignPackageCard extends StatelessWidget {
  const ForeignPackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context
            .read<PackagesBloc>()
            .add(const ForeignPackageCheckoutRequested()),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF024D87).withValues(alpha: 0.05),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF024D87).withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF51B1E1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'GLOBAL MOBILITY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF51B1E1),
                      ),
                    ),
                  ),
                  const Icon(Icons.public, color: Color(0xFF024D87)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Foreign Package',
                style: GoogleFonts.manrope(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Specialized curation for international applications and visa-sponsored opportunities.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF3E4A3C),
                ),
              ),
              const SizedBox(height: 32),
              const _MiniFeatureCard(
                title: 'ATS CV (Global Format)',
                subtitle:
                    'Scannable architecture for Oracle, Workday & Taleo systems.',
              ),
              const SizedBox(height: 16),
              const _MiniFeatureCard(
                title: 'Statement of Purpose',
                subtitle:
                    'Premium academic or professional personal narrative.',
              ),
              const SizedBox(height: 16),
              const _MiniFeatureCard(
                title: 'LinkedIn Optimization',
                subtitle: 'Full profile overhaul including SEO headlines.',
              ),
              const SizedBox(height: 16),
              const _MiniFeatureCard(
                title: 'Academic CV',
                subtitle:
                    'Tailored for research and international institutions.',
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$299',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  Text(
                    'VAT inclusive',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3E4A3C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: 'Go Global, proceed to payment',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF024D87), Color(0xFF28A745)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF024D87).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Go Global',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

class _MiniFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MiniFeatureCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191C1D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF3E4A3C),
            ),
          ),
        ],
      ),
    );
  }
}

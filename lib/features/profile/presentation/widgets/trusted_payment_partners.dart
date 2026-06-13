import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_colors.dart';

class TrustedPaymentPartners extends StatelessWidget {
  const TrustedPaymentPartners({super.key});

  static const _bkash =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDGfrCTkvoE2OmGjYunFjPtqTEC4T-I7UkB7nqWmHWrCLeNXJ0DPG8wPcGH63IDA9JCq27Qm8uf6Eb0gV6AJNJ2vMlPOclSRcY-LnbDAyxHGkvc5WxQzRbs6Q5-4VaRZpVkdtBzkBlN9F3uTglLcmxUOV6cSf3rPF1Xj7WvuDDAbWIPQzhL3wh7dNxkR36GN-55FqP2Sd1mtUR_vFaUoPxnA7ebw8PoGM2LPib4FChn82HmlI_jSf2UoIsdmzkFOeMRwOv_7b8FJJM';
  static const _nagad =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC-XaZDPQD9bFDLKZajflt88uaVSvslbzTTDCd_6JlyXI-SPWS4P-CS3G0YO6oJTUjR6q2JLYI0hzhcRDEHRTB-kid6zcGw3dFkoqKJIBuqg7qDQJm9FIvoohIC_0Or0kOVsPn1MHtsonTCoefz1n3ptAEEaYEWrV1NRWrtVrsBvK3EQdLcM4saMWbzVDDq7i3jbl1f0KS8bGgJLo7vGHWoiPGlSlKjz_ckdDKeCe9gyR1S09ZatF7ys6R_WDEomyQ7lUMRAZ3ZRAw';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'TRUSTED PAYMENT PARTNERS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: ProfileColors.outline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PartnerLogo(url: _bkash),
            const SizedBox(width: 40),
            _PartnerLogo(url: _nagad),
          ],
        ),
      ],
    );
  }
}

class _PartnerLogo extends StatelessWidget {
  const _PartnerLogo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        height: 32,
        width: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ProfileColors.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(Icons.payment, size: 18),
        ),
      ),
    );
  }
}

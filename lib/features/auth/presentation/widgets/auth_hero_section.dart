import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_bloc.dart';
import '../../../../core/utils/auth_strings.dart';

class AuthHeroSection extends StatelessWidget {
  const AuthHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final lang = state.languageCode;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AuthStrings.get('loginHeroTitle', lang),
                style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1D),
                  letterSpacing: -0.5,
                ) : GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AuthStrings.get('loginHeroSubtitle', lang),
                textAlign: TextAlign.center,
                style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                  fontSize: 16,
                  color: const Color(0xFF3E4A3C),
                  height: 1.625,
                ) : GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF3E4A3C),
                  height: 1.625,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

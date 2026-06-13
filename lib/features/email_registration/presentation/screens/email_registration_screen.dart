import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/bloc/language_bloc.dart';
import '../../../../core/utils/auth_strings.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../auth/presentation/widgets/primary_gradient_button.dart';
import '../bloc/email_registration_bloc.dart';
import '../widgets/email_reg_top_bar.dart';
import '../widgets/email_input_card.dart';
import '../widgets/email_reg_footer.dart';

class EmailRegistrationScreen extends StatefulWidget {
  const EmailRegistrationScreen({super.key});

  @override
  State<EmailRegistrationScreen> createState() =>
      _EmailRegistrationScreenState();
}

class _EmailRegistrationScreenState extends State<EmailRegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmailRegistrationBloc(),
      child: BlocListener<EmailRegistrationBloc, EmailRegistrationState>(
        listener: (context, state) {
          if (state is EmailRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Email updated successfully!',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF006E25),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate to dashboard after brief delay so snackbar is visible
            Future.delayed(const Duration(milliseconds: 800), () {
              if (context.mounted) _navigateToDashboard();
            });
          } else if (state is EmailRegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            final lang = langState.languageCode;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: const Color(0xFFF3F4F5),
                body: Stack(
                  children: [
                    // Decorative ambient blobs
                    Positioned(
                      top: -80,
                      left: -80,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x0D006E25),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0D006E25),
                              blurRadius: 100,
                              spreadRadius: 60,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      right: -60,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x0DAB2D57),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0DAB2D57),
                              blurRadius: 120,
                              spreadRadius: 60,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          EmailRegTopBar(onSkip: _navigateToDashboard),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 448,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _LocalizedEmailHero(lang: lang),
                                      // EmailInputCard wired to BLoC via onChanged
                                      BlocBuilder<
                                        EmailRegistrationBloc,
                                        EmailRegistrationState
                                      >(
                                        builder: (context, state) {
                                          return EmailInputCard(
                                            controller: _emailController,
                                            hintText: AuthStrings.get(
                                              'emailHint',
                                              lang,
                                            ),
                                            errorText:
                                                state
                                                    is EmailRegistrationInvalid
                                                ? state.errorMessage
                                                : null,
                                            onChanged: (value) {
                                              context
                                                  .read<EmailRegistrationBloc>()
                                                  .add(EmailChanged(value));
                                            },
                                          );
                                        },
                                      ),
                                      _ActionSection(
                                        emailController: _emailController,
                                        onSkip: _navigateToDashboard,
                                        lang: lang,
                                      ),
                                      const SizedBox(height: 40),
                                      const EmailRegFooter(),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LocalizedEmailHero extends StatelessWidget {
  final String lang;

  const _LocalizedEmailHero({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
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
            AuthStrings.get('emailTitle', lang),
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF191C1D),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AuthStrings.get('emailDesc', lang),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF3E4A3C),
              height: 1.625,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSkip;
  final String lang;

  const _ActionSection({
    required this.emailController,
    required this.onSkip,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<EmailRegistrationBloc, EmailRegistrationState>(
          builder: (context, state) {
            final isLoading = state is EmailRegistrationLoading;

            // Button is enabled ONLY when email format is valid
            final isEnabled = state is EmailRegistrationValid;

            return PrimaryGradientButton(
              text: AuthStrings.get('addEmail', lang),
              isLoading: isLoading,
              onPressed: isEnabled
                  ? () {
                      // Check connectivity before making the API call
                      final connectivityState = context
                          .read<ConnectivityBloc>()
                          .state;
                      if (connectivityState is ConnectivityOffline) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No Internet Connection',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFFBA1A1A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        return;
                      }

                      context.read<EmailRegistrationBloc>().add(
                        EmailSubmitted(emailController.text),
                      );
                    }
                  : null,
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6E7B6B),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              AuthStrings.get('skipDashboard', lang),
              style: GoogleFonts.inter(
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0x5066DF75),
                decorationStyle: TextDecorationStyle.solid,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

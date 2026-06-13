import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/language_bloc.dart';
import '../widgets/auth_hero_section.dart';
import '../widgets/phone_input_card.dart';
import '../widgets/auth_footer.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import '../../../../core/widgets/no_internet_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: context.read<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            // BDApps OTP was sent – navigate to verification screen with args.
            Navigator.pushNamed(
              context,
              '/verification',
              arguments: {
                'referenceNo': state.referenceNo,
                'phone': state.phone,
              },
            );
          } else if (state is AuthAuthenticated) {
            final user = state.user;
            final phone = (user?['phoneNumber'] ?? user?['phone'] ?? '').toString();
            if (phone.startsWith('018') || phone.startsWith('016')) {
              // Robi/Airtel authenticated via old flow – go to dashboard.
              Navigator.pushNamed(context, '/dashboard');
            } else {
              Navigator.pushNamed(context, '/email_registration');
            }
          } else if (state is AuthEmailRequired) {
            Navigator.pushNamed(context, '/email_registration');
          } else if (state is AuthError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            final isOffline = connectivityState is ConnectivityOffline;

            if (isOffline) {
              print("Auth Screen Network: Offline");
              return NoInternetScreen(
                onRetry: () => context.read<AuthBloc>().add(const CheckAuthStatus()),
              );
            }

            print("Auth Screen Network: Online");

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                extendBodyBehindAppBar: true,
                body: Stack(
                  children: [
                  // Background decorations
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
                          BoxShadow(color: Color(0x1A28A745), blurRadius: 80, spreadRadius: 40)
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
                          BoxShadow(color: Color(0x1AEE6189), blurRadius: 80, spreadRadius: 40)
                        ],
                      ),
                    ),
                  ),
                  
                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // Language Toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BlocBuilder<LanguageBloc, LanguageState>(
                                builder: (context, state) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _LanguageOption(
                                          label: 'EN',
                                          isSelected: state.languageCode == 'en',
                                          onTap: () => context.read<LanguageBloc>().add(const ChangeLanguage('en')),
                                        ),
                                        _LanguageOption(
                                          label: 'BN',
                                          isSelected: state.languageCode == 'bn',
                                          onTap: () => context.read<LanguageBloc>().add(const ChangeLanguage('bn')),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 448),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AuthHeroSection(),
                                      PhoneInputCard(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const AuthFooter(),
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

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF024D87) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: label == 'BN' ? GoogleFonts.notoSerifBengali(
            color: isSelected ? Colors.white : const Color(0xFF3E4A3C),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ) : GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF3E4A3C),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

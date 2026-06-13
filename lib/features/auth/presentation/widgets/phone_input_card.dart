import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/storage/user_storage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/language_bloc.dart';
import '../../../../core/utils/auth_strings.dart';
import '../../../../core/network/bloc/connectivity_bloc.dart';
import '../../../../core/network/bloc/connectivity_state.dart';
import 'primary_gradient_button.dart';

class PhoneInputCard extends StatefulWidget {
  const PhoneInputCard({super.key});

  @override
  State<PhoneInputCard> createState() => _PhoneInputCardState();
}

class _PhoneInputCardState extends State<PhoneInputCard> {
  final TextEditingController _phoneController = TextEditingController();
  String _currentPrefixMessage = 'robiAirtelBenefit';

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = _phoneController.text;
    if (text.isEmpty) {
      setState(() {
        _currentPrefixMessage = 'robiAirtelBenefit';
      });
    } else if (text.length >= 3) {
      if (text.startsWith('018') || text.startsWith('016') || text.startsWith('011')) {
        setState(() {
          _currentPrefixMessage = 'robiAirtelBenefit';
        });
      } else {
        setState(() {
          _currentPrefixMessage = 'otherNetworkBenefit';
        });
      }
    } else {
      setState(() {
        _currentPrefixMessage = 'robiAirtelBenefit';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, langState) {
        final lang = langState.languageCode;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
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
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0x4DBDCAB9),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuArylTGeHsMOihzFqc7yi3-t0snJfPNozYq-jz9zsZvWioPG_ru21oY7Nb7Aj9_LgrthrN-Z56NeJC7St_DOAAI_KQrR2MPm9dsqQG-LOaEsi6xM7WBDZ6NvNRrbsnoMF1z1dGphmxKi-oB5IJ0IJYV7qSiUC2_1qccSe7ZGRiwagpqgYPtqiebYzHB8JhH1-ojXLJFzIKBGl8tj997MniRy6LHyW3LfCMII_UYeB3DfZSXud9c0dgUobD3JeAVAO6KhB_ko_5VJHs',
                              width: 24,
                              height: 16,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(width: 24, height: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+88',
                            style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191C1D),
                            ) : GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191C1D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF191C1D),
                        ) : GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF191C1D),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AuthStrings.get('phoneHint', lang),
                          hintStyle: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                            fontWeight: FontWeight.w500,
                            color: const Color(0x803E4A3C),
                          ) : GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: const Color(0x803E4A3C),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_currentPrefixMessage.isNotEmpty)
                Text(
                  AuthStrings.get(_currentPrefixMessage, lang),
                  textAlign: TextAlign.center,
                  style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _currentPrefixMessage == 'robiAirtelBenefit' ? Colors.black : Colors.black,
                    letterSpacing: 0.25,
                  ) : GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _currentPrefixMessage == 'robiAirtelBenefit' ? Colors.black : Colors.black,
                    letterSpacing: 0.25,
                  ),
                ),
              if (_currentPrefixMessage.isNotEmpty) const SizedBox(height: 24),
              Text(
                AuthStrings.get('otpSentDesc', lang),
                textAlign: TextAlign.center,
                style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3E4A3C),
                  letterSpacing: 0.25,
                ) : GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3E4A3C),
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ConnectivityBloc, ConnectivityState>(
                builder: (context, connectivityState) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryGradientButton(
                        text: AuthStrings.get('sendCode', lang),
                        isLoading: state is AuthLoading,
                        onPressed: () async {
                          if (connectivityState is ConnectivityOffline) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No Internet Connection'),
                              ),
                            );
                            return;
                          }

                          final localNumber = _phoneController.text.trim();

                          if (localNumber.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AuthStrings.get('enterPhone', lang)),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(localNumber)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AuthStrings.get('invalidPhone', lang)),
                              ),
                            );
                            return;
                          }

                          print('[PhoneInputCard] Sending phone: $localNumber');
                          
                          if (localNumber.startsWith('018') ||
                              localNumber.startsWith('016')) {
                            
                            print("Using existing check_subscription result");
                            
                            // Use existing stored status
                            final isRegistered = await UserStorage.getSubscriptionStatus();
                            
                            if (isRegistered) {
                              print("Robi/Airtel REGISTERED → direct login");
                              try {
                                // Call auth API directly
                                await AuthService.loginWithPhone(localNumber);
                                
                                // Tokens and user data are already saved inside loginWithPhone()
                                
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/email_registration');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                              return; // STOP execution
                            } else {
                              print("Robi/Airtel UNREGISTERED → OTP");
                              context
                                  .read<AuthBloc>()
                                  .add(SendOtpRequested(localNumber));
                            }
                          } else {
                            print("Other operator → unchanged");
                            context
                                .read<AuthBloc>()
                                .add(SubmitPhoneNumber(localNumber));
                          }
                        },
                         );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

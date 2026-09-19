import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/language_bloc.dart';
import '../../../../core/utils/auth_strings.dart';
import '../../../auth/presentation/widgets/auth_top_bar.dart';
import '../../../auth/presentation/widgets/primary_gradient_button.dart';
import '../bloc/verification_bloc.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _currentPin = '';

  // Keyboard fix: FocusNode initialised in initState so it survives rebuilds
  // and the keyboard reopens every time the user taps the OTP field.
  late FocusNode _otpFocusNode;

  // OTP length is now 6 digits (BDApps requirement).
  static const int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read route arguments passed from AuthScreen.
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final referenceNo = args?['referenceNo'] as String? ?? '';
    final phone = args?['phone'] as String? ?? '';

    return BlocProvider(
      create: (_) => VerificationBloc(),
      // Outer listener: AuthBloc handles real OTP verification result.
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
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
                backgroundColor: const Color(0xFFF8F9FA),
                body: Stack(
                  children: [
                    // Background decorations matching Auth Screen style.
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
                            BoxShadow(
                              color: Color(0x1A28A745),
                              blurRadius: 80,
                              spreadRadius: 40,
                            ),
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
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          const AuthTopBar(),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 48,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 448,
                                  ),
                                  child: Container(
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
                                    child: Stack(
                                      children: [
                                        _buildHiddenInput(),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AuthStrings.get(
                                                'verificationTitle',
                                                lang,
                                              ),
                                              style: GoogleFonts.manrope(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF191C1D),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              AuthStrings.get(
                                                'verificationDesc6',
                                                lang,
                                              ),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: const Color(0xFF3E4A3C),
                                                height: 1.625,
                                              ),
                                            ),
                                            if (phone.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                phone,
                                                style: GoogleFonts.manrope(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF024D87),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 32),
                                            // Keyboard fix: always request focus
                                            // on tap so keyboard reopens every time.
                                            GestureDetector(
                                              onTap: () {
                                                // Forcibly re-engage the system
                                                // keyboard: drop focus first so
                                                // Flutter does not skip the IME
                                                // show call when the node already
                                                // holds logical focus, then
                                                // immediately request it back.
                                                _otpFocusNode.unfocus();
                                                Future.microtask(() {
                                                  if (context.mounted) {
                                                    FocusScope.of(context).requestFocus(_otpFocusNode);
                                                  }
                                                });
                                              },
                                              child: _buildPinField(),
                                            ),
                                            const SizedBox(height: 32),
                                            BlocBuilder<AuthBloc, AuthState>(
                                              builder: (context, state) {
                                                return PrimaryGradientButton(
                                                  text: AuthStrings.get(
                                                    'verifyOtp',
                                                    lang,
                                                  ),
                                                  isLoading:
                                                      state is AuthLoading,
                                                  onPressed: () {
                                                    if (_currentPin.length ==
                                                        _otpLength) {
                                                      context
                                                          .read<AuthBloc>()
                                                          .add(
                                                            OtpVerified(
                                                              otp: _currentPin,
                                                              referenceNo:
                                                                  referenceNo,
                                                              phone: phone,
                                                            ),
                                                          );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            AuthStrings.get(
                                                              'invalidOtp6',
                                                              lang,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            // Resend OTP option
                                            TextButton(
                                              onPressed: () {
                                                if (phone.isNotEmpty) {
                                                  context.read<AuthBloc>().add(
                                                    SendOtpRequested(phone),
                                                  );
                                                  setState(
                                                    () => _currentPin = '',
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'OTP resent successfully',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Resend OTP',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: const Color(0xFF024D87),
                                                  fontWeight: FontWeight.w600,
                                                ),
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

  Widget _buildPinField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_otpLength, (index) {
        final char = _currentPin.length > index ? _currentPin[index] : '';
        return Container(
          width: 46,
          height: 54,
          decoration: BoxDecoration(
            color: char.isNotEmpty ? Colors.white : const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: char.isNotEmpty
                  ? const Color(0xFF024D87)
                  : const Color(0x4DBDCAB9),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            char,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191C1D),
            ),
          ),
        );
      }),
    );
  }

  // Hidden text input that captures keystrokes for the custom PIN field.
  Widget _buildHiddenInput() {
    return SizedBox(
      height: 0,
      width: 0,
      child: TextField(
        focusNode: _otpFocusNode,
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: _otpLength,
        enableInteractiveSelection: true,
        onChanged: (v) {
          setState(() {
            _currentPin = v;
          });
        },
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}

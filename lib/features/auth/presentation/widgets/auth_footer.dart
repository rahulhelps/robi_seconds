import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_bloc.dart';

import '../screens/legal_content_screen.dart';

// You can replace these with your actual text constants
const String dummyTermsText = '''
QuickCV Pro - Terms & Conditions

1. Introduction
By using QuickCV Pro, you confirm that you accept these terms and agree to comply with them. If you do not agree, please do not use the application.

2. Use of the App
QuickCV Pro provides tools to create CVs, cover letters, SOPs, and professional emails. You agree to use the app only for lawful purposes and not misuse its features.

3. User Responsibility
You are responsible for the accuracy of the information you provide and the content you generate. We do not guarantee job placement or outcomes.

4. Account & Authentication
You may be required to verify your phone number or provide additional details. You are responsible for maintaining the security of your account.

5. Subscription & Payments
Some features may require a subscription. All pricing is clearly shown in the app. Access to premium features is granted after successful payment.

6. Intellectual Property
All app content, features, and design are owned by QuickCV Pro. You may not copy, modify, or distribute any part of the app without permission.

7. Service Availability
We aim to provide uninterrupted service but do not guarantee that the app will always be available or error-free.

8. Limitation of Liability
We are not responsible for any indirect or consequential loss resulting from the use of the app or generated content.

9. Changes to Terms
We may update these Terms at any time. Continued use of the app means you accept the updated terms.

10. Contact
If you have any questions, contact us at:
wahedalam.geo@gmail.com
''';

const String dummyPrivacyText = '''
QuickCV Pro - Privacy Policy

1. Introduction
Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use QuickCV Pro.

2. Information We Collect
We may collect:
- Phone number for authentication
- Email address (if provided)
- Profile data and generated documents
- Basic usage data for app improvement

3. How We Use Information
We use your information to:
- Provide app functionality
- Authenticate users securely
- Store and manage your documents
- Improve user experience

4. Data Storage & Security
Your data is stored securely. We take reasonable measures to protect your information from unauthorized access.

5. Data Sharing
We do not sell or rent your personal data. We may share data only when required by law or to prevent misuse.

6. User Control
You can update your information or request data deletion at any time.

7. Third-Party Services
We may use trusted third-party services for analytics and performance monitoring.

8. Children's Privacy
This app is not intended for children under 13. We do not knowingly collect data from children.

9. Changes to Policy
We may update this Privacy Policy from time to time. Continued use of the app means you accept the updated policy.

10. Contact
For any questions, contact:
wahedalam.geo@gmail.com
''';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final lang = state.languageCode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: lang == 'bn' ? GoogleFonts.notoSerifBengali(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3E4A3C),
                letterSpacing: 0.55,
                height: 1.625,
              ) : GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3E4A3C),
                letterSpacing: 0.55,
                height: 1.625,
              ),
              children: [
                const TextSpan(text: 'BY CONTINUING, YOU AGREE TO OUR\n'),
                TextSpan(
                  text: 'TERMS & CONDITIONS',
                  style: lang == 'bn' 
                      ? GoogleFonts.notoSerifBengali(color: const Color(0xFF024D87))
                      : GoogleFonts.inter(color: const Color(0xFF024D87)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalContentScreen(
                            title: "Terms & Conditions",
                            content: dummyTermsText,
                          ),
                        ),
                      );
                    },
                ),
                const TextSpan(text: ' AND '),
                TextSpan(
                  text: 'PRIVACY POLICY',
                  style: lang == 'bn' 
                      ? GoogleFonts.notoSerifBengali(color: const Color(0xFF024D87))
                      : GoogleFonts.inter(color: const Color(0xFF024D87)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalContentScreen(
                            title: "Privacy Policy",
                            content: dummyPrivacyText,
                          ),
                        ),
                      );
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        );
      },
    );
  }
}

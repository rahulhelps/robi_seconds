import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Screens
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/auth/presentation/screens/subscription_expired_screen.dart';
import 'features/auth/presentation/screens/subscription_pending_screen.dart';
import 'features/verification/presentation/screens/verification_screen.dart';
import 'features/email_registration/presentation/screens/email_registration_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/cv_builder/presentation/screens/template_gallery_screen.dart';
import 'features/cv_builder/presentation/screens/cv_list_screen.dart';
import 'features/cover_letter/presentation/screens/cover_letter_screen.dart';
import 'features/professional_email/presentation/screens/email_template_screen.dart';
import 'features/mock_test/presentation/screens/mock_test_screen.dart';
import 'core/error_screens/error_screens.dart';
import 'core/network/api_client.dart';

// Data / Domain
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/data/auth_datasource.dart';
import 'features/cv_builder/domain/cv_repository.dart';
import 'features/cv_builder/data/cv_datasource.dart';
import 'features/cover_letter/domain/cover_letter_repository.dart';
import 'features/cover_letter/data/cover_letter_datasource.dart';
import 'features/sop/domain/sop_repository.dart';
import 'features/sop/data/sop_repository_impl.dart';
import 'features/sop/data/sop_datasource.dart';
import 'features/sop/presentation/screens/sop_template_screen.dart';
import 'features/sop/presentation/bloc/sop_bloc.dart';
import 'features/sop/data/sop_pdf_generator.dart';
import 'features/professional_email/domain/email_repository.dart';
import 'features/professional_email/data/email_repository_impl.dart';
import 'features/professional_email/data/email_datasource.dart';
import 'features/professional_email/data/email_pdf_generator.dart';
import 'features/professional_email/presentation/bloc/email_bloc.dart';
import 'features/profile/presentation/screens/profile_settings_screen.dart';
import 'features/profile/presentation/screens/my_documents_screen.dart';

import 'features/documents/domain/document_repository.dart';
import 'features/documents/data/documents_datasource.dart';
import 'features/documents/presentation/bloc/documents_bloc.dart';

// BLoCs
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/language_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/packages/presentation/bloc/packages_bloc.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';
import 'core/network/bloc/connectivity_bloc.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // dark icons = visible on light background
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthRepository(AuthDataSource()),
        ),
        RepositoryProvider(
          create: (_) => CvRepository(CvDatasource()),
        ),
        RepositoryProvider(
          create: (_) => CoverLetterRepository(CoverLetterDatasource()),
        ),
        RepositoryProvider<SopRepository>(
          create: (_) => SopRepositoryImpl(SopDatasource()),
        ),
        RepositoryProvider<EmailRepository>(
          create: (_) => EmailRepositoryImpl(EmailDatasource()),
        ),
        RepositoryProvider<DocumentRepository>(
          create: (_) => DocumentRepository(DocumentsDatasource()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>())..add(const CheckAuthStatus()),
          ),
          BlocProvider(
            create: (context) => LanguageBloc(),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(),
          ),
          BlocProvider(
            create: (context) =>
                PackagesBloc()..add(const FetchPackages()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(),
          ),
          BlocProvider(
            create: (context) => PaymentBloc()..add(LoadPaymentData()),
          ),
          BlocProvider(
            create: (context) => ConnectivityBloc(),
          ),
          BlocProvider(
            create: (context) => SopBloc(
              context.read<SopRepository>(),
              SopPdfGenerator(),
            )..add(const SopHistoryRequested()),
          ),
          BlocProvider(
            create: (context) => EmailBloc(
              context.read<EmailRepository>(),
              EmailPdfGenerator(),
            )..add(const EmailHistoryRequested()),
          ),
          BlocProvider(
            create: (context) => DocumentsBloc(
              context.read<DocumentRepository>(),
            )..add(const DocumentsFetchRequested()),
          ),
        ],
          child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.read<ProfileBloc>().add(const ResetProfile());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigatorKey.currentState?.pushNamedAndRemoveUntil('/splash', (route) => false);
              });
            } else if (state is AuthAuthenticated) {
              context.read<ProfileBloc>().add(const FetchProfile());
            }
          },
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'QuickCV Pro',
            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF024D87),
                primary: const Color(0xFF024D87),
                brightness: Brightness.light,
              ),
              primaryColor: const Color(0xFF024D87),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF024D87),
                foregroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light, // light icons for dark AppBar
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Color(0xFF024D87),
                backgroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF024D87),
                  foregroundColor: Colors.white,
                ),
              ),
              // cardTheme: const CardTheme(
              //   color: Color(0xFFF4F8FB),
              //   elevation: 0,
              // ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/auth': (_) => const AuthScreen(),
              '/verification': (_) => const VerificationScreen(),
              '/email_registration': (_) => const EmailRegistrationScreen(),
              '/dashboard': (_) => const QuickCVDashboardScreen(),
              '/template_gallery': (_) => const TemplateGalleryScreen(),
              '/cv_list': (_) => const CvListScreen(),
              '/cover_letter': (_) => const CoverLetterScreen(),
              '/subscription_expired': (_) => const SubscriptionExpiredScreen(),
              '/subscription_pending': (_) => const SubscriptionPendingScreen(),
              '/sop': (_) => const SopTemplateScreen(),
              '/email': (_) => const EmailTemplateScreen(),
              '/mock_test': (_) => const MockTestScreen(),
              '/profile_settings': (_) => const ProfileSettingsScreen(),
              '/my_documents': (_) => const MyDocumentsScreen(),
              '/error/403': (_) => const ForbiddenScreen(),
              '/error/404': (_) => const NotFoundScreen(),
              '/error/419': (_) => const PageExpiredScreen(),
              '/error/500': (_) => const ServerErrorScreen(),
            },
          ),
        ),
      ),
    );
  }
}

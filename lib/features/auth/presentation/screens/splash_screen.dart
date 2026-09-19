import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/storage/user_storage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Logo bounce ──────────────────────────────────────────────────────────
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // ── Ring pulse ───────────────────────────────────────────────────────────
  late final AnimationController _ringController;

  // ── Text reveal ──────────────────────────────────────────────────────────
  late final AnimationController _textController;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // ── Tagline ──────────────────────────────────────────────────────────────
  late final AnimationController _tagController;
  late final Animation<double> _tagOpacity;

  // ── Progress bar ─────────────────────────────────────────────────────────
  late final AnimationController _progressController;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // Logo bounce in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Infinite ring pulse
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Text slides up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    // Tagline fades in
    _tagController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tagOpacity = CurvedAnimation(parent: _tagController, curve: Curves.easeIn);

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _progressValue = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _startSequence();
  }

  /// Calls [controller].forward() only when the widget is still mounted.
  /// Flutter guarantees dispose() runs after unmount, so mounted == true
  /// means all AnimationControllers are still alive.
  void _safeForward(AnimationController controller) {
    if (mounted) controller.forward();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _safeForward(_logoController);
    _safeForward(_progressController);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _safeForward(_textController);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _safeForward(_tagController);

    // Wait for the progress animation to finish, then check login state.
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final accessToken = await TokenManager.getAccessToken();
    if (!mounted) return;

    if (accessToken != null && accessToken.isNotEmpty) {
      // Token exists – check subscription status via BDApps.
      final phone = await UserStorage.getPhone();
      if (!mounted) return;

      if (phone != null && phone.isNotEmpty) {
        // Dispatch to AuthBloc; BlocListener below handles navigation.
        context.read<AuthBloc>().add(CheckSubscriptionStatus(phone));
      } else {
        // No stored phone – go straight to dashboard as a safe fallback.
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      // No session – show Auth screen.
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }


  @override
  void dispose() {
    _logoController.dispose();
    _ringController.dispose();
    _textController.dispose();
    _tagController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!context.mounted) return;
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (state is AuthEmailRequired) {
          Navigator.pushReplacementNamed(context, '/email_registration');
        } else if (state is AuthSubscriptionExpired) {
          Navigator.pushReplacementNamed(
            context,
            '/subscription_expired',
            arguments: {'phone': state.phone},
          );
        } else if (state is AuthSubscriptionPending) {
          Navigator.pushReplacementNamed(
            context,
            '/subscription_pending',
            arguments: {'phone': state.phone},
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF003D14),
              Color(0xFF024D87),
              Color(0xFF028A30),
              Color(0xFF00B140),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Background decorative blobs ─────────────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(color: const Color(0xFF83FC8E).withValues(alpha: 0.15), size: 280),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: _GlowOrb(color: const Color(0xFFFFFFFF).withValues(alpha: 0.06), size: 220),
            ),
            Positioned(
              top: 120,
              left: -100,
              child: _GlowOrb(color: const Color(0xFF024D87).withValues(alpha: 0.3), size: 320),
            ),

            // ── Dot grid overlay ────────────────────────────────────────
            Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

            // ── Main content ────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Pulsing rings + logo
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring pulse
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (_, _) {
                              final t = _ringController.value;
                              return Opacity(
                                opacity: (1 - t) * 0.35,
                                child: Transform.scale(
                                  scale: 0.7 + t * 0.6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    width: 180,
                                    height: 180,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Middle ring pulse (offset phase)
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (_, _) {
                              final t = (_ringController.value + 0.4) % 1.0;
                              return Opacity(
                                opacity: (1 - t) * 0.2,
                                child: Transform.scale(
                                  scale: 0.7 + t * 0.6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    width: 180,
                                    height: 180,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Logo container
                          ScaleTransition(
                            scale: _logoScale,
                            child: FadeTransition(
                              opacity: _logoOpacity,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF83FC8E).withValues(alpha: 0.25),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.description_rounded,
                                    color: Colors.white,
                                    size: 52,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'QuickCV Pro',
                            style: GoogleFonts.manrope(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Tagline
                          FadeTransition(
                            opacity: _tagOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Build. Stand Out. Get Hired.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _progressValue,
                          builder: (_, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _progressValue.value,
                                minHeight: 3,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _tagOpacity,
                          child: Text(
                            'Loading your workspace…',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}

// ── Decorative glow orb ────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ── Dot grid background ────────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeCap = StrokeCap.round;

    const spacing = 28.0;
    const dotRadius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

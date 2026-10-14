import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/ambient_side_gradient_background.dart';
import 'auth/login_screen.dart';
import 'auth/complete_profile_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _subSlide;
  late Animation<double> _subFade;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    // 3.6s unified animation for silky smooth 60/120fps playback without initial hitch
    _animController = AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    );

    // 1. Expanding shockwave ripple (0.0s -> 1.0s)
    _rippleScale = Tween<double>(begin: 0.3, end: 1.5).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOutCubic),
      ),
    );
    _rippleFade = Tween<double>(begin: 0.75, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeOut),
      ),
    );

    // 2. Logo entrance with smooth damped curve (0.2s -> 1.4s)
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.08, 0.42, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.06, 0.28, curve: Curves.easeIn),
      ),
    );

    // 3. Title entrance (1.0s -> 1.8s)
    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.50, curve: Curves.easeIn),
      ),
    );

    // 4. Subtitle entrance (1.4s -> 2.2s)
    _subSlide = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.38, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _subFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.38, 0.62, curve: Curves.easeIn),
      ),
    );

    // 5. Sleek progress indicator (0.6s -> 3.5s)
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.18, 0.94, curve: Curves.easeInOutCubic),
      ),
    );

    _animController.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // 3.8s total duration giving user 3-4 full seconds to experience welcome animation
    await Future.delayed(const Duration(milliseconds: 3800));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // If logged in, wait briefly for profile if needed
    if (authProvider.isLoggedIn && authProvider.profile == null) {
      int retries = 0;
      while (authProvider.profile == null && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 150));
        retries++;
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (!authProvider.isLoggedIn) return const LoginScreen();
          if (!authProvider.isProfileComplete) return const CompleteProfileScreen();
          return const HomeScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: AmbientSideGradientBackground(
        child: SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 50 || constraints.maxHeight <= 50) {
                return const SizedBox.shrink();
              }

              return Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        final val = _animController.value;
                        // Continuous smooth orbital angle across the 3.6s
                        final orbitalAngle = val * 4 * math.pi;
                        // Subtle floating wave
                        final floatOffset = 3.0 * math.sin(val * 4 * math.pi);
                        final pulseScale = 1.0 + 0.025 * math.sin(val * 4 * math.pi);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── HERO WELCOME LOGO (icon1.png) ──
                            RepaintBoundary(
                              child: SizedBox(
                                width: 170,
                                height: 170,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Shockwave expanding ripple
                                    if (_rippleFade.value > 0.01)
                                      Transform.scale(
                                        scale: _rippleScale.value,
                                        child: Opacity(
                                          opacity: _rippleFade.value.clamp(0.0, 1.0),
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF38BDF8),
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Outer soft glow aura
                                    Opacity(
                                      opacity: _logoFade.value.clamp(0.0, 1.0),
                                      child: Container(
                                        width: 136,
                                        height: 136,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF38BDF8)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 32,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Rotating Orbital Arc Ring (Smooth, hardware-accelerated)
                                    Opacity(
                                      opacity: (_logoFade.value * 0.9).clamp(0.0, 1.0),
                                      child: Transform.rotate(
                                        angle: orbitalAngle,
                                        child: CustomPaint(
                                          size: const Size(130, 130),
                                          painter: const _OrbitalRingPainter(),
                                        ),
                                      ),
                                    ),

                                    // Counter-rotating accent dots
                                    Opacity(
                                      opacity: (_logoFade.value * 0.7).clamp(0.0, 1.0),
                                      child: Transform.rotate(
                                        angle: -orbitalAngle * 0.6,
                                        child: Container(
                                          width: 124,
                                          height: 124,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Central circular icon1.png
                                    Opacity(
                                      opacity: _logoFade.value.clamp(0.0, 1.0),
                                      child: Transform.translate(
                                        offset: Offset(0, floatOffset),
                                        child: Transform.scale(
                                          scale: _logoScale.value * pulseScale,
                                          child: Container(
                                            width: 110,
                                            height: 110,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFF5DB3DE),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.3),
                                                width: 2.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                                                  blurRadius: 18,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'icons/icon1.png',
                                                width: 110,
                                                height: 110,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(
                                                  Icons.key_rounded,
                                                  color: Colors.white,
                                                  size: 58,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── TITLE (Smooth Slide & Fade) ──
                            Opacity(
                              opacity: _textFade.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, _textSlide.value),
                                child: const Text(
                                  'NIS Digital Store',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFF38BDF8),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── SUBTITLE ──
                            Opacity(
                              opacity: _subFade.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, _subSlide.value),
                                child: Text(
                                  'PREMIUM DIGITAL STORE & SERVICES',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.4 * _subFade.value.clamp(0.3, 1.0),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // ── PROGRESS BAR (3-4s pacing) ──
                            Opacity(
                              opacity: _textFade.value.clamp(0.0, 1.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 190,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: 190 * _progressAnim.value.clamp(0.0, 1.0),
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF0284C7),
                                              Color(0xFF38BDF8),
                                              Colors.white,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF38BDF8).withValues(alpha: 0.65),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _getStatusMessage(_progressAnim.value),
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 10,
                                      letterSpacing: 2.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(double progress) {
    if (progress < 0.30) {
      return 'INITIALIZING DIGITAL STORE...';
    } else if (progress < 0.65) {
      return 'CONNECTING SECURE DATABASE...';
    } else if (progress < 0.90) {
      return 'SYNCING STORE OFFERS...';
    } else {
      return 'WELCOME TO NIS DIGITAL STORE!';
    }
  }
}

/// Lightweight, hardware-accelerated orbital arc painter
class _OrbitalRingPainter extends CustomPainter {
  const _OrbitalRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF38BDF8),
          Colors.transparent,
          Color(0xFF06B6D4),
          Colors.transparent,
          Color(0xFF38BDF8),
        ],
      ).createShader(rect);

    canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

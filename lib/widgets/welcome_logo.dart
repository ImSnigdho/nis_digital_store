import 'dart:math' as math;
import 'package:flutter/material.dart';

class WelcomeLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final bool showOuterRings;

  const WelcomeLogo({
    super.key,
    this.size = 80,
    this.animate = true,
    this.showOuterRings = true,
  });

  @override
  State<WelcomeLogo> createState() => _WelcomeLogoState();
}

class _WelcomeLogoState extends State<WelcomeLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    if (widget.animate) {
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _buildStaticLogo();
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final val = _animController.value;
        // Smooth breathing pulse: 1.0 -> 1.04 -> 1.0
        final pulseScale = 1.0 + 0.04 * math.sin(val * 2 * math.pi);
        // Subtle floating bobbing: -3px -> +3px
        final floatOffset = 3.0 * math.sin(val * 2 * math.pi);
        // Pulsing glow radius
        final glowAlpha = 0.35 + 0.15 * math.sin(val * 2 * math.pi);

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: pulseScale,
            child: _buildLogoWithGlow(glowAlpha: glowAlpha),
          ),
        );
      },
    );
  }

  Widget _buildStaticLogo() {
    return _buildLogoWithGlow(glowAlpha: 0.4);
  }

  Widget _buildLogoWithGlow({required double glowAlpha}) {
    final s = widget.size;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer soft ambient glow ring
        if (widget.showOuterRings)
          Container(
            width: s + 24,
            height: s + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: glowAlpha * 0.7),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: glowAlpha * 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

        // Main circular logo container with icon1.png
        Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5DB3DE),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'icons/icon1.png',
              width: s,
              height: s,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF5DB3DE),
                child: Center(
                  child: Icon(
                    Icons.key_rounded,
                    size: s * 0.55,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

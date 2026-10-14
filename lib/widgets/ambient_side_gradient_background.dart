import 'package:flutter/material.dart';

class AmbientSideGradientBackground extends StatelessWidget {
  final Widget child;

  const AmbientSideGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Deep midnight gradient background (Cached in RepaintBoundary)
        const RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0C1322),
                  Color(0xFF0F172A),
                  Color(0xFF080D1A),
                ],
              ),
            ),
            child: SizedBox.expand(),
          ),
        ),

        // 2. Corner / ambient floating orbs (Cached)
        RepaintBoundary(
          child: IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  right: -60,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF06B6D4).withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Side & edge gradients matching Screenshot 4 (Cached)
        RepaintBoundary(
          child: IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Left side gradient
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.32),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Right side gradient
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.32),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top edge gradient
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom edge gradient
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Perimeter neon frame matching Screenshot 4
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const SizedBox.expand(),
                ),
              ],
            ),
          ),
        ),

        // 4. Content child
        child,
      ],
    );
  }
}

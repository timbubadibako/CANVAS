import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Continuous pulse animation for corners
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color glowColor = AppColors.studioIndigo.withValues(
      alpha: isDark ? 0.15 : 0.1,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSplash : Colors.white,
      body: Stack(
        children: [
          // 1. Top-Left Pulsating Glow
          Positioned(top: -100, left: -100, child: _buildGlow(glowColor)),

          // 2. Bottom-Right Pulsating Glow
          Positioned(bottom: -100, right: -100, child: _buildGlow(glowColor)),

          // 3. Central Logo (Safe from Glow Overlap)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withValues(
                      //         alpha: isDark ? 0.3 : 0.05,
                      //       ),
                      //       blurRadius: 40,
                      //       offset: const Offset(0, 20),
                      //     ),R
                      //   ],
                      // ),
                      child: Image.asset(
                        isDark
                            ? 'assets/images/logo.png'
                            : 'assets/images/logo_light.jpeg',
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'STUDIO CANVAS',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: AppColors.paintGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 350 * _pulseAnimation.value,
          height: 350 * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        );
      },
    );
  }
}

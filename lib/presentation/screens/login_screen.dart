import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/main_nav_wrapper.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpPressed;
  const LoginScreen({super.key, required this.onSignUpPressed});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 300, height: 300, 
                decoration: BoxDecoration(
                  color: AppColors.studioIndigo.withValues(alpha: isDark ? 0.1 : 0.05), 
                  shape: BoxShape.circle
                )
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 40),
                    Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text('Sign in to sync your canvas logs.', 
                      style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 16)
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(context, label: 'STUDIO EMAIL', hint: 'artist@canvas.io'),
                    const SizedBox(height: 24),
                    _buildTextField(context, label: 'ACCESS KEY', hint: '••••••••', isPassword: true),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavWrapper())),
                      child: const Text('SIGN IN'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: widget.onSignUpPressed,
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have a palette? ",
                            style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted),
                            children: [
                              TextSpan(text: 'Sign Up', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 80, width: 80,
      decoration: BoxDecoration(
        gradient: AppColors.paintGradient, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.studioIndigo.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: const Icon(Icons.palette, color: Colors.white, size: 40),
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, required String hint, bool isPassword = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 10
        )),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
          decoration: InputDecoration(
            hintText: hint,
            // Uses decoration from AppTheme
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

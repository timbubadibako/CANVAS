import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'preferences_screen.dart';

class RegisterScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  const RegisterScreen({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onBackPressed,
                icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : AppColors.lightText),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 32),
              Text('New Palette', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Start your journey with CANVAS.', 
                style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 16)
              ),
              const SizedBox(height: 48),
              _buildTextField(context, label: 'FULL NAME', hint: 'Claude Monet'),
              const SizedBox(height: 24),
              _buildTextField(context, label: 'STUDIO EMAIL', hint: 'artist@canvas.io'),
              const SizedBox(height: 24),
              _buildTextField(context, label: 'ACCESS KEY', hint: '••••••••', isPassword: true),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OnboardingPreferencesScreen()), (route) => false);
                },
                child: const Text('CREATE ACCOUNT'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

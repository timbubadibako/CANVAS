import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'preferences_screen.dart';

class RegisterScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  const RegisterScreen({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
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
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 32),
              Text('New Palette', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Start your journey with CANVAS.', style: TextStyle(color: AppColors.slateMuted, fontSize: 16)),
              const SizedBox(height: 48),
              _buildTextField(label: 'FULL NAME', hint: 'Claude Monet'),
              const SizedBox(height: 24),
              _buildTextField(label: 'STUDIO EMAIL', hint: 'artist@canvas.io'),
              const SizedBox(height: 24),
              _buildTextField(label: 'ACCESS KEY', hint: '••••••••', isPassword: true),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const OnboardingPreferencesScreen()), 
                    (route) => false,
                  );
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

  Widget _buildTextField({required String label, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.slateMuted)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: AppColors.slateCard.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

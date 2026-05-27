import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import '../widgets/main_nav_wrapper.dart';
import 'preferences_screen.dart';
import '../bloc/auth/auth_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpPressed;
  const LoginScreen({super.key, required this.onSignUpPressed});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Memicu OS untuk menyimpan password
      TextInput.finishAutofillContext();
      context.read<AuthBloc>().add(AuthSignInRequested(_emailController.text, _passController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          print('[LoginScreen] Auth Success. isNewUser: ${state.isNewUser}');
          StudioToast.show(context, 'WELCOME TO STUDIO', icon: LucideIcons.palette);
          
          if (state.isNewUser) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const OnboardingPreferencesScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const MainNavWrapper()),
            );
          }
        } else if (state is AuthUnauthenticated) {
          if (state.prefilledEmail != null) {
            print('[LoginScreen] Received prefilled credentials for ${state.prefilledEmail}');
            setState(() {
              _emailController.text = state.prefilledEmail!;
              _passController.text = state.prefilledPassword ?? "";
            });
            print('[LoginScreen] Controllers updated. Email: ${_emailController.text}');
          }
        } else if (state is AuthFailure) {
          StudioToast.show(context, 'AUTH ERROR: ${state.message}', icon: LucideIcons.alertCircle);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                Positioned(
                  top: -100, left: -100,
                  child: Container(width: 300, height: 300, decoration: BoxDecoration(color: AppColors.studioIndigo.withValues(alpha: isDark ? 0.1 : 0.05), shape: BoxShape.circle)),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            _buildLogo(),
                            const SizedBox(height: 40),
                            Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text('Sign in to sync your canvas logs.', style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 16)),
                            const SizedBox(height: 48),
                            
                            _buildTextField(
                              context, 
                              label: 'STUDIO EMAIL', 
                              hint: 'artist@canvas.io', 
                              controller: _emailController, 
                              autofillHints: const [AutofillHints.email],
                              validator: (v) => (v == null || v.isEmpty) ? 'Email is required' : null
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              context, 
                              label: 'ACCESS KEY', 
                              hint: '••••••••', 
                              isPassword: true, 
                              obscureText: _obscurePassword,
                              controller: _passController, 
                              autofillHints: const [AutofillHints.password],
                              onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                              validator: (v) => (v == null || v.length < 6) ? 'Password min. 6 chars' : null
                            ),
                            
                            const SizedBox(height: 60),
                            
                            ElevatedButton(
                              onPressed: state is AuthLoading ? null : _submit,
                              child: state is AuthLoading 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('SIGN IN'),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildTextField(BuildContext context, {
    required String label, 
    required String hint, 
    bool isPassword = false, 
    bool obscureText = false,
    required TextEditingController controller, 
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
    VoidCallback? onToggleVisibility,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 10)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          validator: validator,
          autofillHints: autofillHints,
          style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            errorStyle: const TextStyle(color: AppColors.deepRose, fontWeight: FontWeight.bold, fontSize: 10),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(obscureText ? LucideIcons.eye : LucideIcons.eyeOff, size: 20, color: AppColors.slateMuted),
              onPressed: onToggleVisibility,
            ) : null,
          ),
        ),
      ],
    );
  }
}

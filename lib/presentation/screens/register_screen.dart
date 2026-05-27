import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import '../bloc/auth/auth_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  const RegisterScreen({super.key, required this.onBackPressed});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Memicu OS untuk menyimpan password
      TextInput.finishAutofillContext();
      context.read<AuthBloc>().add(AuthSignUpRequested(
        _emailController.text, _passController.text, _nameController.text
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated && state.prefilledEmail != null) {
          print('[AuthFlow] Registration success. Auto-routing back to Login with email: ${state.prefilledEmail}');
          StudioToast.show(context, 'PALETTE CREATED! PLEASE SIGN IN.', icon: LucideIcons.checkCircle);
          widget.onBackPressed(); // Menggeser PageView kembali ke layar Login
        } else if (state is AuthFailure) {
          StudioToast.show(context, 'REGISTRATION FAILED: ${state.message}', icon: LucideIcons.alertCircle);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: widget.onBackPressed,
                        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : AppColors.lightText),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 32),
                      Text('New Palette', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Start your journey with CANVAS.', style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 16)),
                      const SizedBox(height: 48),
                      
                      _buildTextField(
                        context, 
                        label: 'FULL NAME', 
                        hint: 'Claude Monet', 
                        controller: _nameController, 
                        autofillHints: const [AutofillHints.name],
                        validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        context, 
                        label: 'STUDIO EMAIL', 
                        hint: 'artist@canvas.io', 
                        controller: _emailController, 
                        autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
                        validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        context, 
                        label: 'ACCESS KEY', 
                        hint: '••••••••', 
                        isPassword: true, 
                        obscureText: _obscurePassword,
                        controller: _passController, 
                        autofillHints: const [AutofillHints.newPassword],
                        onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) => (v == null || v.length < 6) ? 'Min. 6 characters' : null
                      ),
                      
                      const SizedBox(height: 60),
                      
                      ElevatedButton(
                        onPressed: state is AuthLoading ? null : _submit,
                        child: state is AuthLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('CREATE ACCOUNT'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

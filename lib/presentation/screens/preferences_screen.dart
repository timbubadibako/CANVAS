import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import '../../core/utils/nutrition_calculator.dart';
import '../widgets/main_nav_wrapper.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../../../domain/models/user_profile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OnboardingPreferencesScreen extends StatefulWidget {
  const OnboardingPreferencesScreen({super.key});

  @override
  State<OnboardingPreferencesScreen> createState() => _OnboardingPreferencesScreenState();
}

class _OnboardingPreferencesScreenState extends State<OnboardingPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Data State
  String? _selectedGoal;
  String? _gender;
  int? _age;
  double? _weight;
  int? _height;
  String? _dietaryStyle;
  String? _activityLevel;
  String? _strategy;
  String? _motivation;

  void _nextStep() {
    // Validasi Wajib untuk SEMUA STEP
    if (_currentStep == 0 && _selectedGoal == null) {
      StudioToast.show(context, 'PLEASE SELECT A PRIMARY GOAL', icon: LucideIcons.alertCircle);
      return;
    }
    if (_currentStep == 1) {
      if (_gender == null || _age == null || _height == null || _weight == null) {
        StudioToast.show(context, 'ALL BODY CANVAS DATA REQUIRED', icon: LucideIcons.alertCircle);
        return;
      }
    }
    if (_currentStep == 2) {
      if (_activityLevel == null || _dietaryStyle == null) {
        StudioToast.show(context, 'PLEASE SELECT ACTIVITY & DIETARY STYLE', icon: LucideIcons.alertCircle);
        return;
      }
    }
    if (_currentStep == 3 && _strategy == null) {
      StudioToast.show(context, 'PLEASE CHOOSE A STRATEGY', icon: LucideIcons.alertCircle);
      return;
    }
    if (_currentStep == 4 && _motivation == null) {
      StudioToast.show(context, 'PLEASE SHARE YOUR MOTIVATION', icon: LucideIcons.alertCircle);
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart);
      setState(() => _currentStep++);
    } else {
      _saveProfileToSupabase();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart);
      setState(() => _currentStep--);
    }
  }

  void _saveProfileToSupabase() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      double bmr = NutritionCalculator.calculateBMR(weightKg: _weight!, heightCm: _height!, age: _age!, gender: _gender!);
      double tdee = NutritionCalculator.calculateTDEE(bmr: bmr, activityLevel: _activityLevel!);
      int targetKcal = NutritionCalculator.calculateTargetCalories(tdee: tdee, fitnessStrategy: _strategy!);
      Map<String, double> macros = NutritionCalculator.calculateMacros(targetCalories: targetKcal, weightKg: _weight!, fitnessStrategy: _strategy!);

      final updatedProfile = UserProfile(
        id: authState.user.id,
        fullName: authState.user.userMetadata?['full_name'] ?? 'Canvas Artist',
        gender: _gender,
        age: _age,
        heightCm: _height,
        weightKg: _weight,
        primaryGoal: _selectedGoal,
        dietaryPalette: _dietaryStyle,
        activityLevel: _activityLevel,
        motivation: _motivation,
        fitnessStrategy: _strategy?.toLowerCase(),
        dailyCalorieTarget: targetKcal,
        dailyProteinTarget: macros['protein'],
        dailyCarbsTarget: macros['carbs'],
        dailyFatTarget: macros['fat'],
      );

      context.read<ProfileBloc>().add(UpdateProfileRequested(updatedProfile));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          StudioToast.show(context, 'MASTERPIECE SAVED TO CLOUD', icon: LucideIcons.cloud);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavWrapper()));
        } else if (state is ProfileFailure) {
          StudioToast.show(context, 'SYNC ERROR: ${state.message}', icon: LucideIcons.alertTriangle);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _previousStep();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildDotProgressBar(isDark),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildGoalStep(isDark),
                      _buildStatsStep(isDark),
                      _buildDietaryStep(isDark),
                      _buildStrategyStep(isDark),
                      _buildMotivationStep(isDark),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          child: TextButton(
                            onPressed: _previousStep,
                            child: const Text('BACK'),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              if (state is ProfileLoading) {
                                return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
                              }
                              return Text(_currentStep == _totalSteps - 1 ? 'FINISH MASTERPIECE' : 'NEXT STEP');
                            },
                          ),
                        ),
                      ),
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

  Widget _buildDotProgressBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
          final bool isCurrent = index == _currentStep;
          final bool isPassed = index < _currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 10,
            width: isCurrent ? 32 : 10,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isCurrent || isPassed ? AppColors.studioIndigo : (isDark ? Colors.white12 : Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGoalStep(bool isDark) {
    return _buildStepContainer(
      title: "What's your\nPrimary Goal?",
      subtitle: "Select the focus of your nutritional canvas.",
      isDark: isDark,
      child: Column(
        children: [
          _buildSelectCard("Weight Loss", "Burn fat and improve definition.", LucideIcons.zap, _selectedGoal, (v) => _selectedGoal = v, isDark),
          const SizedBox(height: 16),
          _buildSelectCard("Build Muscle", "Increase strength and volume.", LucideIcons.dumbbell, _selectedGoal, (v) => _selectedGoal = v, isDark),
          const SizedBox(height: 16),
          _buildSelectCard("Stay Healthy", "Maintain balance and energy.", LucideIcons.heart, _selectedGoal, (v) => _selectedGoal = v, isDark),
        ],
      ),
    );
  }

  Widget _buildStatsStep(bool isDark) {
    return _buildStepContainer(
      title: "The Body\nCanvas",
      subtitle: "Age and Gender are critical for calculating your BMR accurately.",
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end, // Align bottom to match textfield height
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BIOLOGICAL SEX", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSmallChip("Male", _gender == "Male", () => setState(() => _gender = "Male"), isDark, height: 60),
                        const SizedBox(width: 16),
                        _buildSmallChip("Female", _gender == "Female", () => setState(() => _gender = "Female"), isDark, height: 60),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildStatInput("AGE", _age?.toString() ?? "", "YRS", (val) => setState(() => _age = int.tryParse(val)), isDark)),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatInput("HEIGHT", _height?.toString() ?? "", "CM", (val) => setState(() => _height = int.tryParse(val)), isDark),
          const SizedBox(height: 24),
          _buildStatInput("CURRENT WEIGHT", _weight?.toString() ?? "", "KG", (val) => setState(() => _weight = double.tryParse(val)), isDark),
        ],
      ),
    );
  }

  Widget _buildDietaryStep(bool isDark) {
    return _buildStepContainer(
      title: "Dietary\nPalette",
      subtitle: "Daily activity and eating style.",
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ACTIVITY LEVEL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSmallChip("Sedentary", _activityLevel == "Sedentary", () => setState(() => _activityLevel = "Sedentary"), isDark, height: 64),
              const SizedBox(width: 8),
              _buildSmallChip("Moderate", _activityLevel == "Moderate", () => setState(() => _activityLevel = "Moderate"), isDark, height: 64),
              const SizedBox(width: 8),
              _buildSmallChip("Active", _activityLevel == "Active", () => setState(() => _activityLevel = "Active"), isDark, height: 64),
            ],
          ),
          const SizedBox(height: 32),
          Text("EATING STYLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildSelectCard("Everything", "No specific restrictions.", LucideIcons.utensils, _dietaryStyle, (v) => _dietaryStyle = v, isDark),
          const SizedBox(height: 12),
          _buildSelectCard("Vegetarian", "Plant-based focus.", LucideIcons.leaf, _dietaryStyle, (v) => _dietaryStyle = v, isDark),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, bool isSelected, VoidCallback onTap, bool isDark, {double height = 50}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.studioIndigo : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? AppColors.slateMuted : AppColors.lightMuted)))),
        ),
      ),
    );
  }

  Widget _buildStrategyStep(bool isDark) {
    return _buildStepContainer(
      title: "Nutritional\nStrategy",
      subtitle: "Choose the intensity of your masterpiece.",
      isDark: isDark,
      child: Column(
        children: [
          _buildStrategyCard("Cutting", "Intense calorie deficit for fat loss.", AppColors.deepRose, isDark),
          const SizedBox(height: 16),
          _buildStrategyCard("Maintenance", "Perfect balance for current physique.", AppColors.studioIndigo, isDark),
          const SizedBox(height: 16),
          _buildStrategyCard("Bulking", "Surplus for peak muscle growth.", AppColors.vibrantEmerald, isDark),
        ],
      ),
    );
  }

  Widget _buildMotivationStep(bool isDark) {
    return _buildStepContainer(
      title: "Why do you\nCreate?",
      subtitle: "This stays between us. Your motivation matters.",
      isDark: isDark,
      child: Column(
        children: [
          _buildSelectCard("Health Recovery", "To manage health issues.", LucideIcons.activity, _motivation, (v) => _motivation = v, isDark),
          const SizedBox(height: 16),
          _buildSelectCard("Athletic Peak", "For intense training performance.", LucideIcons.trophy, _motivation, (v) => _motivation = v, isDark),
          const SizedBox(height: 16),
          _buildSelectCard("Self Confidence", "To feel and look my best version.", LucideIcons.smile, _motivation, (v) => _motivation = v, isDark),
          const SizedBox(height: 16),
          _buildSelectCard("Longevity", "To live a long, vibrant life.", LucideIcons.heartPulse, _motivation, (v) => _motivation = v, isDark),
        ],
      ),
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required Widget child, required bool isDark}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(subtitle, style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 15)),
        const SizedBox(height: 48),
        child,
      ]),
    );
  }

  Widget _buildSelectCard(String title, String desc, IconData icon, String? groupValue, Function(String) onSelect, bool isDark) {
    final bool isSelected = groupValue == title;

    return GestureDetector(
      onTap: () => setState(() => onSelect(title)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.studioIndigo.withValues(alpha: 0.1) : (isDark ? AppColors.slateCard : AppColors.lightCard), 
          borderRadius: BorderRadius.circular(32), 
          border: Border.all(color: isSelected ? AppColors.studioIndigo : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)))
        ),
        child: Row(children: [
          Icon(icon, color: isSelected ? AppColors.studioIndigo : (isDark ? AppColors.slateMuted : AppColors.lightMuted), size: 24),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.lightText)),
            Text(desc, style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 11)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildStatInput(String label, String value, String unit, Function(String) onChanged, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? AppColors.slateMuted : AppColors.lightMuted)),
      const SizedBox(height: 12),
      TextField(
        onChanged: onChanged, keyboardType: TextInputType.number, 
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightText), 
        decoration: InputDecoration(
          suffixText: unit, suffixStyle: const TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.bold), 
          filled: true, fillColor: isDark ? AppColors.slateCard : AppColors.lightCard, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), 
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)
        )
      ),
    ]);
  }

  Widget _buildStrategyCard(String title, String desc, Color color, bool isDark) {
    final bool isSelected = _strategy == title;

    return GestureDetector(
      onTap: () => setState(() => _strategy = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : (isDark ? AppColors.slateCard : AppColors.lightCard), 
          borderRadius: BorderRadius.circular(32), 
          border: Border.all(color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)))
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isSelected ? color : (isDark ? Colors.white : AppColors.lightText))),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ]),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 12)),
        ]),
      ),
    );
  }
}

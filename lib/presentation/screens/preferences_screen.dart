import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/main_nav_wrapper.dart';
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
  String _selectedGoal = "Weight Loss";
  double _weight = 70.0;
  int _height = 170;
  String _strategy = "Maintenance";
  String _dietaryStyle = "Everything";
  String _activityLevel = "Moderate";
  String _motivation = "Personal Health";

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart);
      setState(() => _currentStep++);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavWrapper()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGoalStep(),
                  _buildStatsStep(),
                  _buildDietaryStep(),
                  _buildStrategyStep(),
                  _buildMotivationStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(_currentStep == _totalSteps - 1 ? 'FINISH MASTERPIECE' : 'NEXT STEP'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4, margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: isActive ? AppColors.studioIndigo : Colors.white12, borderRadius: BorderRadius.circular(2)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGoalStep() {
    return _buildStepContainer(
      title: "What's your\nPrimary Goal?",
      subtitle: "Select the focus of your nutritional canvas.",
      child: Column(
        children: [
          _buildSelectCard("Weight Loss", "Burn fat and improve definition.", LucideIcons.zap, _selectedGoal, (v) => _selectedGoal = v),
          const SizedBox(height: 16),
          _buildSelectCard("Build Muscle", "Increase strength and volume.", LucideIcons.dumbbell, _selectedGoal, (v) => _selectedGoal = v),
          const SizedBox(height: 16),
          _buildSelectCard("Stay Healthy", "Maintain balance and energy.", LucideIcons.heart, _selectedGoal, (v) => _selectedGoal = v),
        ],
      ),
    );
  }

  Widget _buildStatsStep() {
    return _buildStepContainer(
      title: "The Body\nCanvas",
      subtitle: "Help us understand your current physical state.",
      child: Column(
        children: [
          _buildStatInput("HEIGHT", _height.toString(), "CM", (val) => setState(() => _height = int.tryParse(val) ?? _height)),
          const SizedBox(height: 24),
          _buildStatInput("CURRENT WEIGHT", _weight.toString(), "KG", (val) => setState(() => _weight = double.tryParse(val) ?? _weight)),
        ],
      ),
    );
  }

  Widget _buildDietaryStep() {
    return _buildStepContainer(
      title: "Dietary\nPalette",
      subtitle: "Daily activity and eating style.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ACTIVITY LEVEL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSmallChip("Sedentary", _activityLevel == "Sedentary", () => setState(() => _activityLevel = "Sedentary")),
              const SizedBox(width: 8),
              _buildSmallChip("Moderate", _activityLevel == "Moderate", () => setState(() => _activityLevel = "Moderate")),
              const SizedBox(width: 8),
              _buildSmallChip("Active", _activityLevel == "Active", () => setState(() => _activityLevel = "Active")),
            ],
          ),
          const SizedBox(height: 32),
          Text("EATING STYLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildSelectCard("Everything", "No specific restrictions.", LucideIcons.utensils, _dietaryStyle, (v) => _dietaryStyle = v),
          const SizedBox(height: 12),
          _buildSelectCard("Vegetarian", "Plant-based focus.", LucideIcons.leaf, _dietaryStyle, (v) => _dietaryStyle = v),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.studioIndigo : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.slateMuted))),
        ),
      ),
    );
  }

  Widget _buildStrategyStep() {
    return _buildStepContainer(
      title: "Nutritional\nStrategy",
      subtitle: "Choose the intensity of your masterpiece.",
      child: Column(
        children: [
          _buildStrategyCard("Cutting", "Intense calorie deficit for fat loss.", AppColors.deepRose),
          const SizedBox(height: 16),
          _buildStrategyCard("Maintenance", "Perfect balance for current physique.", AppColors.studioIndigo),
          const SizedBox(height: 16),
          _buildStrategyCard("Bulking", "Surplus for peak muscle growth.", AppColors.vibrantEmerald),
        ],
      ),
    );
  }

  Widget _buildMotivationStep() {
    return _buildStepContainer(
      title: "Why do you\nCreate?",
      subtitle: "This stays between us. Your motivation matters.",
      child: Column(
        children: [
          _buildSelectCard("Health Recovery", "To manage health issues.", LucideIcons.activity, _motivation, (v) => _motivation = v),
          const SizedBox(height: 16),
          _buildSelectCard("Athletic Peak", "For intense training performance.", LucideIcons.trophy, _motivation, (v) => _motivation = v),
          const SizedBox(height: 16),
          _buildSelectCard("Self Confidence", "To feel and look my best version.", LucideIcons.smile, _motivation, (v) => _motivation = v),
          const SizedBox(height: 16),
          _buildSelectCard("Longevity", "To live a long, vibrant life.", LucideIcons.heartPulse, _motivation, (v) => _motivation = v),
        ],
      ),
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(subtitle, style: const TextStyle(color: AppColors.slateMuted, fontSize: 15)),
        const SizedBox(height: 48),
        child,
      ]),
    );
  }

  Widget _buildSelectCard(String title, String desc, IconData icon, String groupValue, Function(String) onSelect) {
    final bool isSelected = groupValue == title;
    return GestureDetector(
      onTap: () => setState(() => onSelect(title)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isSelected ? AppColors.studioIndigo.withValues(alpha: 0.1) : AppColors.slateCard, borderRadius: BorderRadius.circular(32), border: Border.all(color: isSelected ? AppColors.studioIndigo : Colors.white.withValues(alpha: 0.05))),
        child: Row(children: [
          Icon(icon, color: isSelected ? AppColors.studioIndigo : AppColors.slateMuted, size: 24),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(desc, style: const TextStyle(color: AppColors.slateMuted, fontSize: 11)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildStatInput(String label, String value, String unit, Function(String) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.slateMuted)),
      const SizedBox(height: 12),
      TextField(onChanged: onChanged, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), decoration: InputDecoration(suffixText: unit, suffixStyle: const TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.bold), filled: true, fillColor: AppColors.slateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20))),
    ]);
  }

  Widget _buildStrategyCard(String title, String desc, Color color) {
    final bool isSelected = _strategy == title;
    return GestureDetector(
      onTap: () => setState(() => _strategy = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.1) : AppColors.slateCard, borderRadius: BorderRadius.circular(32), border: Border.all(color: isSelected ? color : Colors.white.withValues(alpha: 0.05))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isSelected ? color : Colors.white)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ]),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppColors.slateMuted, fontSize: 12)),
        ]),
      ),
    );
  }
}

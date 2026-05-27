import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import '../../core/utils/nutrition_calculator.dart';
import '../../core/utils/studio_image_processor.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../../../domain/models/user_profile.dart';
import '../../../data/repositories/food_repository_impl.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ImagePicker _picker = ImagePicker();
  
  bool _isAccountExpanded = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: "");

  bool _notifEnabled = true;
  bool _isManualUpdate = false;
  double _todayKcal = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _controller.forward();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(LoadProfileRequested(authState.user.id));
      _emailController.text = authState.user.email ?? "";
      _loadTodayKcal(authState.user.id);
    }
  }

  void _loadTodayKcal(String userId) async {
    final logs = await FoodRepositoryImpl().getTodayLogs(userId);
    if (mounted) {
      setState(() {
        _todayKcal = logs.fold(0, (sum, item) => sum + item.caloriesKcal);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.08, (index * 0.1 + 0.5).clamp(0, 1), curve: Curves.easeOutQuart),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Future<void> _handleImageWorkflow(ImageSource source, String userId) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      if (mounted) {
        // Add a small delay to ensure picker activity is fully closed before cropper starts
        await Future.delayed(const Duration(milliseconds: 200));
        
        final processedFile = await StudioImageProcessor.processAvatar(context, pickedFile.path);
        if (processedFile != null && mounted) {
          _isManualUpdate = true;
          context.read<ProfileBloc>().add(UpdateAvatarRequested(userId, processedFile.path));
        }
      }
    } catch (e) {
      if (mounted) StudioToast.show(context, 'PROCESS ERROR', icon: LucideIcons.alertCircle);
    }
  }

  void _showEditProfile(UserProfile profile) {
    final nameCtrl = TextEditingController(text: profile.fullName);
    final heightCtrl = TextEditingController(text: profile.heightCm?.toString() ?? "");
    final weightCtrl = TextEditingController(text: profile.weightKg?.toString() ?? "");
    final ageCtrl = TextEditingController(text: profile.age?.toString() ?? "");

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 32),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 32),
            const Text('EDIT STUDIO PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: AppColors.studioIndigo)),
            const SizedBox(height: 24),
            _buildInnerField('Artist Name', nameCtrl),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildInnerField('Age', ageCtrl, isNum: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildInnerField('Height (cm)', heightCtrl, isNum: true)),
            ]),
            const SizedBox(height: 16),
            _buildInnerField('Weight (kg)', weightCtrl, isNum: true),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _isManualUpdate = true;
                final updated = profile.copyWith(fullName: nameCtrl.text, age: int.tryParse(ageCtrl.text), heightCm: int.tryParse(heightCtrl.text), weightKg: double.tryParse(weightCtrl.text));
                context.read<ProfileBloc>().add(UpdateProfileRequested(updated));
                Navigator.pop(context);
              },
              child: const Text('SAVE MASTERPIECE'),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  void _showEditPreferences(UserProfile profile) {
    String selectedGoal = profile.primaryGoal ?? 'Stay Healthy';
    String selectedActivity = profile.activityLevel ?? 'Moderate';
    String selectedStrategy = profile.fitnessStrategy ?? 'maintenance';

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 32),
              const Text('STUDIO PREFERENCES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.studioIndigo, letterSpacing: 1.2)),
              const SizedBox(height: 24),
              _buildSelectionLabel('PRIMARY GOAL'),
              const SizedBox(height: 12),
              _buildSelectionGrid(['Weight Loss', 'Build Muscle', 'Stay Healthy'], selectedGoal, (v) => setModalState(() => selectedGoal = v!)),
              const SizedBox(height: 24),
              _buildSelectionLabel('ACTIVITY LEVEL'),
              const SizedBox(height: 12),
              _buildSelectionGrid(['Sedentary', 'Moderate', 'Active'], selectedActivity, (v) => setModalState(() => selectedActivity = v!)),
              const SizedBox(height: 24),
              _buildSelectionLabel('FITNESS STRATEGY'),
              const SizedBox(height: 12),
              _buildSelectionGrid(['cutting', 'maintenance', 'bulking'], selectedStrategy, (v) => setModalState(() => selectedStrategy = v!)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _isManualUpdate = true;
                  double weight = profile.weightKg ?? 70.0;
                  int height = profile.heightCm ?? 170;
                  int age = profile.age ?? 25;
                  String gender = profile.gender ?? 'Male';
                  double bmr = NutritionCalculator.calculateBMR(weightKg: weight, heightCm: height, age: age, gender: gender);
                  double tdee = NutritionCalculator.calculateTDEE(bmr: bmr, activityLevel: selectedActivity);
                  int targetKcal = NutritionCalculator.calculateTargetCalories(tdee: tdee, fitnessStrategy: selectedStrategy);
                  Map<String, double> macros = NutritionCalculator.calculateMacros(targetCalories: targetKcal, weightKg: weight, fitnessStrategy: selectedStrategy);
                  final updated = profile.copyWith(primaryGoal: selectedGoal, activityLevel: selectedActivity, fitnessStrategy: selectedStrategy, dailyCalorieTarget: targetKcal, dailyProteinTarget: macros['protein'], dailyCarbsTarget: macros['carbs'], dailyFatTarget: macros['fat']);
                  context.read<ProfileBloc>().add(UpdateProfileRequested(updated));
                  Navigator.pop(context);
                },
                child: const Text('UPDATE CALCULATION'),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionLabel(String label) { return Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.2)); }

  Widget _buildSelectionGrid(List<String> options, String current, Function(String?) onSelect) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: options.map((opt) {
        final bool isSelected = current == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isSelected ? AppColors.studioIndigo : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)), borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.studioIndigo : Colors.transparent)), child: Text(opt.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? AppColors.slateMuted : AppColors.lightMuted)))),
        );
      }).toList(),
    );
  }

  void _showAvatarPicker(String userId) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('CHANGE AVATAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.studioIndigo, letterSpacing: 1.2)),
          const SizedBox(height: 32),
          _buildActionItem(LucideIcons.camera, 'Take New Photo', () { Navigator.pop(context); _handleImageWorkflow(ImageSource.camera, userId); }, isDark: isDark),
          _buildActionItem(LucideIcons.image, 'Choose from Gallery', () { Navigator.pop(context); _handleImageWorkflow(ImageSource.gallery, userId); }, isDark: isDark),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          if (_isManualUpdate) {
            StudioToast.show(context, 'STUDIO SYNCED', icon: LucideIcons.cloud);
            _isManualUpdate = false;
          }
          _nameController.text = state.profile.fullName;
        } else if (state is ProfileFailure) {
          StudioToast.show(context, 'SYNC ERROR: ${state.message}', icon: LucideIcons.alertCircle);
          _isManualUpdate = false;
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final bool isDark = themeMode == ThemeMode.dark;
          return Scaffold(
            body: SafeArea(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) return const Center(child: CircularProgressIndicator());
                  if (state is ProfileFailure) return _buildErrorState(state.message);
                  if (state is ProfileLoaded) {
                    final p = state.profile;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _stagger(0, _buildProfileHeader(p)),
                        const SizedBox(height: 32),
                        _stagger(1, _buildPhysicalMatrix(p)),
                        const SizedBox(height: 32),
                        _stagger(2, Text('GOAL CANVAS', style: _sectionStyle)),
                        const SizedBox(height: 16),
                        _stagger(3, _buildGoalsCard(p)),
                        const SizedBox(height: 32),
                        _stagger(4, Text('STUDIO SETTINGS', style: _sectionStyle)),
                        const SizedBox(height: 16),
                        _stagger(5, _buildAccountRevealItem(p)),
                        _stagger(6, _buildSettingItem(LucideIcons.settings2, 'Studio Preferences', 'Update goals & activity', () => _showEditPreferences(p))),
                        _stagger(7, _buildToggleItem(LucideIcons.bell, 'Notifications', 'App reminders & alerts', _notifEnabled, (v) => setState(() => _notifEnabled = v))),
                        _stagger(8, _buildToggleItem(isDark ? LucideIcons.moon : LucideIcons.sun, 'Studio Theme', isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode', isDark, (v) => context.read<ThemeCubit>().toggleTheme())),
                        _stagger(9, _buildSettingItem(LucideIcons.shieldCheck, 'Privacy & Data', 'Encryption & Usage Policy', () => _showPrivacyPolicy())),
                        _stagger(10, _buildSettingItem(LucideIcons.helpCircle, 'Studio FAQ & Docs', 'AI Model, Accuracy, About', () => _showFaqDocs())),
                        const SizedBox(height: 40),
                        _stagger(11, _buildLogoutBtn()),
                        const SizedBox(height: 120),
                      ]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(LucideIcons.alertTriangle, color: AppColors.deepRose, size: 48),
        const SizedBox(height: 24),
        Text('CONNECTION FAILED', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepRose, fontSize: 16)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.slateMuted, fontSize: 12)),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) context.read<ProfileBloc>().add(LoadProfileRequested(authState.user.id));
        }, child: const Text('RETRY SYNC'))
      ]),
    );
  }

  Widget _buildProfileHeader(UserProfile p) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      _buildOrganicAvatar(p.avatarUrl),
      const SizedBox(width: 24),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: isDark ? Colors.white : AppColors.lightText)),
        const SizedBox(height: 4),
        const Text('ELITE CREATOR', style: TextStyle(color: AppColors.studioIndigo, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ])),
      GestureDetector(onTap: () => _showEditProfile(p), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.edit3, size: 18, color: AppColors.studioIndigo))),
    ]);
  }

  Widget _buildOrganicAvatar(String? url) {
    return GestureDetector(
      onTap: () {
        final state = context.read<ProfileBloc>().state;
        if (state is ProfileLoaded) _showAvatarPicker(state.profile.id);
      },
      child: Container(
        height: 80, width: 80,
        decoration: const BoxDecoration(gradient: AppColors.paintGradient, borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(45))),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(33), topRight: Radius.circular(18), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(43))),
          clipBehavior: Clip.antiAlias,
          child: url != null ? Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(LucideIcons.user, color: Colors.white24, size: 32))) : const Center(child: Icon(LucideIcons.user, color: Colors.white24, size: 32)),
        ),
      ),
    );
  }

  Widget _buildPhysicalMatrix(UserProfile p) {
    return Row(children: [
      Expanded(child: _buildInfoCard('Age', (p.age ?? 0).toString(), 'yrs')),
      const SizedBox(width: 12),
      Expanded(child: _buildInfoCard('Height', (p.heightCm ?? 0).toString(), 'cm')),
      const SizedBox(width: 12),
      Expanded(child: _buildInfoCard('Weight', (p.weightKg ?? 0.0).toStringAsFixed(1), 'kg')),
    ]);
  }

  Widget _buildInfoCard(String label, String value, String unit) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard : AppColors.lightCard, borderRadius: BorderRadius.circular(28), border: isDark ? null : Border.all(color: Colors.indigo.withValues(alpha: 0.05))),
      child: Column(children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.slateMuted)),
        const SizedBox(height: 8),
        RichText(textAlign: TextAlign.center, text: TextSpan(text: value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText), children: [TextSpan(text: '\n$unit', style: const TextStyle(fontSize: 9, color: AppColors.studioIndigo))])),
      ]),
    );
  }

  Widget _buildGoalsCard(UserProfile p) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (p.dailyCalorieTarget > 0) ? (_todayKcal / p.dailyCalorieTarget) : 0;
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard : AppColors.lightCard, borderRadius: BorderRadius.circular(40), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('CALORIE TARGET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('${_todayKcal.toInt()} / ${p.dailyCalorieTarget} KCAL', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 4, backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation<Color>(AppColors.studioIndigo))),
      ]),
    );
  }

  Widget _buildAccountRevealItem(UserProfile p) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_nameController.text.isEmpty) _nameController.text = p.fullName;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart,
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: (isDark ? AppColors.slateCard : AppColors.lightCard).withValues(alpha: _isAccountExpanded ? 0.8 : 0.5), borderRadius: BorderRadius.circular(32), border: Border.all(color: _isAccountExpanded ? AppColors.studioIndigo.withValues(alpha: 0.3) : (isDark ? Colors.transparent : Colors.indigo.withValues(alpha: 0.05)))),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _isAccountExpanded = !_isAccountExpanded), behavior: HitTestBehavior.opaque,
          child: Row(children: [
            const Icon(LucideIcons.user, color: AppColors.slateMuted, size: 20),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Account Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.lightText)), Text('Sync, Email, Phone', style: TextStyle(color: AppColors.slateMuted, fontSize: 11))])),
            AnimatedRotation(turns: _isAccountExpanded ? 0.25 : 0, duration: const Duration(milliseconds: 300), child: const Icon(LucideIcons.chevronRight, color: AppColors.slateMuted, size: 16)),
          ]),
        ),
        ClipRect(child: AnimatedAlign(alignment: Alignment.topCenter, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart, heightFactor: _isAccountExpanded ? 1.0 : 0.0, child: Padding(padding: const EdgeInsets.only(top: 24), child: Column(children: [
          _buildInnerField('STUDIO NAME', _nameController),
          const SizedBox(height: 16),
          _buildInnerField('STUDIO EMAIL', _emailController),
          const SizedBox(height: 16),
          _buildInnerField('PHONE NUMBER', _phoneController),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () { _isManualUpdate = true; final updated = p.copyWith(fullName: _nameController.text); context.read<ProfileBloc>().add(UpdateProfileRequested(updated)); setState(() => _isAccountExpanded = false); }, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('UPDATE ACCOUNT', style: TextStyle(fontSize: 12))),
        ])))),
      ]),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool val, Function(bool) onChanged) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard.withValues(alpha: 0.5) : AppColors.lightCard, borderRadius: BorderRadius.circular(24), border: isDark ? null : Border.all(color: Colors.indigo.withValues(alpha: 0.05))),
      child: Row(children: [
        Icon(icon, color: AppColors.slateMuted, size: 20),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.lightText)), Text(subtitle, style: const TextStyle(color: AppColors.slateMuted, fontSize: 11))])),
        Switch(value: val, onChanged: onChanged, activeThumbColor: AppColors.studioIndigo, activeTrackColor: AppColors.studioIndigo.withValues(alpha: 0.2)),
      ]),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? AppColors.slateCard.withValues(alpha: 0.5) : AppColors.lightCard, borderRadius: BorderRadius.circular(24), border: isDark ? null : Border.all(color: Colors.indigo.withValues(alpha: 0.05))), child: Row(children: [
        Icon(icon, color: AppColors.slateMuted, size: 20),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.lightText)), Text(subtitle, style: const TextStyle(color: AppColors.slateMuted, fontSize: 11))])),
        const Icon(LucideIcons.chevronRight, color: AppColors.slateMuted, size: 16),
      ])),
    );
  }

  Widget _buildLogoutBtn() { return GestureDetector(onTap: _showLogoutConfirmation, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: AppColors.deepRose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.deepRose.withValues(alpha: 0.2))), child: const Center(child: Text('CLOSE STUDIO (LOGOUT)', style: TextStyle(color: AppColors.deepRose, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2))))); }

  void _showLogoutConfirmation() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.logOut, color: AppColors.deepRose, size: 48), const SizedBox(height: 24), Text('CLOSE STUDIO?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.lightText)), const SizedBox(height: 40), Row(children: [Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL'))), const SizedBox(width: 16), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepRose), onPressed: () { context.read<AuthBloc>().add(AuthSignOutRequested()); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthScreen()), (route) => false); }, child: const Text('LOGOUT')))])])));
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap, {bool isDanger = false, required bool isDark}) {
    return GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24)), child: Row(children: [Icon(icon, color: isDanger ? AppColors.deepRose : AppColors.slateMuted, size: 20), const SizedBox(width: 16), Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDanger ? AppColors.deepRose : (isDark ? Colors.white : AppColors.lightText)))])));
  }

  Widget _buildInnerField(String label, TextEditingController controller, {bool isPass = false, bool isNum = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.slateMuted, letterSpacing: 1)), const SizedBox(height: 8), TextField(controller: controller, obscureText: isPass, keyboardType: isNum ? TextInputType.number : TextInputType.text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.lightText), decoration: InputDecoration(isDense: true, filled: true, fillColor: isDark ? Colors.black12 : Colors.indigo.withValues(alpha: 0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))]);
  }

  Widget _buildDocSection(String title, String content) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isDark ? Colors.white : AppColors.lightText)), const SizedBox(height: 8), Text(content, style: const TextStyle(fontSize: 13, color: AppColors.slateMuted, height: 1.6))]));
  }

  TextStyle get _sectionStyle => const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.slateMuted);

  void _showPrivacyPolicy() { showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => Container(height: MediaQuery.of(context).size.height * 0.85, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PRIVACY & DATA POLICY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.studioIndigo)), const SizedBox(height: 32), _buildDocSection('Data Encryption', 'All your nutritional logs and physical data are encrypted using industry-standard protocols.'), _buildDocSection('AI Usage', 'Meal photos are analyzed locally or via secured cloud endpoints to estimate volume.'), const SizedBox(height: 40), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('I UNDERSTAND'))])))); }
  void _showFaqDocs() { showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => Container(height: MediaQuery.of(context).size.height * 0.8, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('STUDIO DOCUMENTATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.studioIndigo)), const SizedBox(height: 32), _buildDocSection('About Developer', 'Developed by Jri as an artistic take on automated nutrition tracking.'), _buildDocSection('About Accuracy', 'AI regression models have ±10-15% variance based on lighting.'), const SizedBox(height: 40)])))); }
}

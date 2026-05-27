import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/auth/auth_bloc.dart';

class NutritionReviewScreen extends StatefulWidget {
  final String initialName;
  final double initialKcal;
  final double initialProtein;
  final double initialCarbs;
  final double initialFat;
  final double initialWeight;
  final VoidCallback? onSaveCompleted;

  const NutritionReviewScreen({
    super.key,
    required this.initialName,
    required this.initialKcal,
    required this.initialProtein,
    required this.initialCarbs,
    required this.initialFat,
    required this.initialWeight,
    this.onSaveCompleted,
  });

  @override
  State<NutritionReviewScreen> createState() => _NutritionReviewScreenState();
}

class _NutritionReviewScreenState extends State<NutritionReviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late String foodName;
  late double portionMultiplier;
  
  @override
  void initState() {
    super.initState();
    foodName = widget.initialName;
    portionMultiplier = 1.0;
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.6).clamp(0.0, 1.0), curve: Curves.easeOutQuart));
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final bool isDark = themeMode == ThemeMode.dark;
        
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stagger(0, _buildHeader(context, isDark)),
                  const SizedBox(height: 32),
                  _stagger(1, _buildArtisticPreview()),
                  const SizedBox(height: 32),
                  _stagger(2, _buildNameInput(isDark)),
                  const SizedBox(height: 32),
                  _stagger(3, _buildNutritionGrid(isDark)),
                  const SizedBox(height: 40),
                  _stagger(4, _buildPortionSlider(isDark)),
                  const SizedBox(height: 48),
                  _stagger(5, _buildActionButtons(context)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, color: isDark ? Colors.white : AppColors.lightText),
        ),
        const SizedBox(width: 8),
        Text('REVIEW MASTERPIECE', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, color: isDark ? Colors.white : AppColors.lightText)),
      ],
    );
  }

  Widget _buildArtisticPreview() {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: AppColors.studioIndigo.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(AppColors.studioIndigo.withValues(alpha: 0.15), BlendMode.color),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            bottom: 24, left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.studioIndigo, borderRadius: BorderRadius.circular(20)),
              child: const Text('STUDIO STYLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('IDENTIFIED AS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => foodName = v,
          controller: TextEditingController(text: foodName),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText),
          decoration: InputDecoration(
            filled: true, fillColor: isDark ? AppColors.slateCard : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.indigo.withValues(alpha: 0.1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildNutriItem('CALORIES', (widget.initialKcal * portionMultiplier).toInt().toString(), 'kcal', AppColors.studioIndigo, isDark),
        _buildNutriItem('PROTEIN', (widget.initialProtein * portionMultiplier).toStringAsFixed(1), 'g', AppColors.studioIndigo, isDark),
        _buildNutriItem('CARBS', (widget.initialCarbs * portionMultiplier).toStringAsFixed(1), 'g', AppColors.energyOrange, isDark),
        _buildNutriItem('FAT', (widget.initialFat * portionMultiplier).toStringAsFixed(1), 'g', AppColors.deepRose, isDark),
      ],
    );
  }

  Widget _buildNutriItem(String label, String value, String unit, Color accent, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slateCard.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText),
              children: [TextSpan(text: ' $unit', style: TextStyle(fontSize: 10, color: accent))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortionSlider(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ADJUST PORTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.5)),
            Text('${(widget.initialWeight * portionMultiplier).toInt()} GRAMS', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.studioIndigo)),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: portionMultiplier,
          min: 0.5, max: 2.0,
          activeColor: AppColors.studioIndigo,
          inactiveColor: isDark ? Colors.white10 : Colors.black12,
          onChanged: (v) => setState(() => portionMultiplier = v),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthAuthenticated) {
                StudioToast.show(context, 'AUTH ERROR', icon: LucideIcons.alertCircle);
                return;
              }

              try {
                final entry = FoodLogEntry(
                  id: const Uuid().v4(),
                  userId: authState.user.id,
                  foodName: foodName,
                  totalMassG: widget.initialWeight * portionMultiplier,
                  caloriesKcal: widget.initialKcal * portionMultiplier,
                  proteinG: widget.initialProtein * portionMultiplier,
                  carbsG: widget.initialCarbs * portionMultiplier,
                  fatG: widget.initialFat * portionMultiplier,
                  createdAt: DateTime.now(),
                  imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
                );

                await FoodRepositoryImpl().saveFoodLog(entry);

                if (context.mounted) {
                  StudioToast.show(context, 'MASTERPIECE SAVED', icon: LucideIcons.checkCircle2);
                  Navigator.pop(context);
                  widget.onSaveCompleted?.call();
                }
              } catch (e) {
                if (context.mounted) {
                  StudioToast.show(context, 'SAVE ERROR: $e', icon: LucideIcons.alertTriangle);
                }
              }
            },
            child: const Text('LOG TO GALLERY'),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/theme_cubit.dart';

class MealDetailScreen extends StatefulWidget {
  final String title;
  final String time;
  final String icon;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;

  const MealDetailScreen({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.6).clamp(0, 1), curve: Curves.easeOutQuart));
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final bool isDark = themeMode == ThemeMode.dark;
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Artistic Header Image
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                stretch: true,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(widget.imageUrl, fit: BoxFit.cover),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              (isDark ? AppColors.deepSlate : AppColors.lightBackground).withValues(alpha: 0.8),
                              isDark ? AppColors.deepSlate : AppColors.lightBackground,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40, left: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.time.toUpperCase(), style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                            const SizedBox(height: 8),
                            Text(widget.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stagger(0, _buildNutritionSummary(isDark)),
                      const SizedBox(height: 40),
                      _stagger(1, Text('COMPOSITION LAYERS', style: _sectionStyle(isDark))),
                      const SizedBox(height: 20),
                      _stagger(2, _buildCompositionCard(isDark, 'Proteins', widget.protein, 'g', AppColors.studioIndigo, 0.7)),
                      const SizedBox(height: 12),
                      _stagger(3, _buildCompositionCard(isDark, 'Carbohydrates', widget.carbs, 'g', AppColors.energyOrange, 0.4)),
                      const SizedBox(height: 12),
                      _stagger(4, _buildCompositionCard(isDark, 'Healthy Fats', widget.fat, 'g', AppColors.deepRose, 0.3)),
                      const SizedBox(height: 40),
                      _stagger(5, _buildActionButtons(isDark)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle _sectionStyle(bool isDark) => const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.slateMuted);

  Widget _buildNutritionSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slateCard : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('${widget.kcal.toInt()}', 'KCAL', isDark),
          Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
          _buildSummaryItem('${widget.protein.toInt()}g', 'PRO', isDark),
          Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
          _buildSummaryItem('${widget.carbs.toInt()}g', 'CARB', isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String val, String label, bool isDark) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.1)),
      ],
    );
  }

  Widget _buildCompositionCard(bool isDark, String label, double value, String unit, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slateCard.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.indigo.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : AppColors.lightText)),
              RichText(text: TextSpan(text: value.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14), children: [TextSpan(text: ' $unit', style: const TextStyle(fontSize: 10, color: AppColors.slateMuted))])),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.share2, size: 18),
            label: const Text('SHARE MASTERPIECE'),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 60, width: 60,
          decoration: BoxDecoration(color: AppColors.deepRose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.deepRose.withValues(alpha: 0.1))),
          child: const Icon(LucideIcons.trash2, color: AppColors.deepRose, size: 20),
        ),
      ],
    );
  }
}

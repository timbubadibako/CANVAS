import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/theme_cubit.dart';
import 'meal_detail_screen.dart';

class MealDiaryScreen extends StatefulWidget {
  const MealDiaryScreen({super.key});

  @override
  State<MealDiaryScreen> createState() => _MealDiaryScreenState();
}

class _MealDiaryScreenState extends State<MealDiaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _selectedFilter = 'All Layers';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.deepSlate : AppColors.lightBackground, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(48))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text('FILTER LAYERS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isDark ? AppColors.slateMuted : AppColors.lightMuted)),
            const SizedBox(height: 24),
            _buildFilterOption('All Layers', LucideIcons.layers),
            _buildFilterOption('High Protein', LucideIcons.zap),
            _buildFilterOption('Low Carbs', LucideIcons.leaf),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon) {
    final bool isSelected = _selectedFilter == label;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.studioIndigo.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.studioIndigo : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.studioIndigo : (isDark ? AppColors.slateMuted : AppColors.lightMuted), size: 20),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? (isDark ? Colors.white : AppColors.lightText) : (isDark ? AppColors.slateMuted : AppColors.lightMuted))),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.studioIndigo, size: 20),
          ],
        ),
      ),
    );
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
                  const SizedBox(height: 40),
                  _stagger(1, _buildDateSection(context, 'Today', isFirst: true, isDark: isDark)),
                  const SizedBox(height: 16),
                  _stagger(2, _buildDiaryItem(context, 'Salmon Palette', '20:15', '🍣', 420, 32, 12, AppColors.studioIndigo, isDark)),
                  const SizedBox(height: 16),
                  _stagger(3, _buildDiaryItem(context, 'Green Canvas', '13:30', '🥗', 280, 15, 8, AppColors.vibrantEmerald, isDark)),
                  const SizedBox(height: 48),
                  _stagger(4, _buildDateSection(context, 'Yesterday', isDark: isDark)),
                  const SizedBox(height: 16),
                  _stagger(5, Opacity(opacity: 0.6, child: _buildDiaryItem(context, 'Pasta Sketch', '19:45', '🍝', 650, 22, 18, AppColors.energyOrange, isDark))),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.5).clamp(0, 1), curve: Curves.easeOutQuart));
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child));
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Meal ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isDark ? Colors.white : AppColors.lightText),
                children: const [TextSpan(text: 'Layers', style: TextStyle(color: AppColors.studioIndigo))],
              ),
            ),
            Text(_selectedFilter.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.2)),
          ],
        ),
        GestureDetector(
          onTap: _showFilterSheet,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 48, width: 48,
            decoration: BoxDecoration(
              color: _selectedFilter != 'All Layers' ? AppColors.studioIndigo : (isDark ? AppColors.slateCard.withValues(alpha: 0.7) : AppColors.lightCard),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.1)),
              boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
            ),
            child: Icon(LucideIcons.filter, size: 20, color: _selectedFilter != 'All Layers' ? Colors.white : (isDark ? AppColors.slateMuted : AppColors.lightMuted)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, String label, {bool isFirst = false, required bool isDark}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: isFirst ? AppColors.paintGradient : null, 
            color: isFirst ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)), 
            borderRadius: BorderRadius.circular(20), 
            border: isFirst ? null : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05))
          ),
          child: Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: isFirst ? Colors.white : (isDark ? AppColors.slateMuted : AppColors.lightMuted))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: isDark ? Colors.white10 : Colors.black12)),
      ],
    );
  }

  Widget _buildDiaryItem(BuildContext context, String title, String time, String icon, double kcal, double protein, double fat, Color accent, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              title: title,
              time: time,
              icon: icon,
              kcal: kcal,
              protein: protein,
              carbs: 25.0,
              fat: fat,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slateCard.withValues(alpha: 0.7) : AppColors.lightCard, 
          borderRadius: BorderRadius.circular(40), 
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              height: 72, width: 72,
              decoration: BoxDecoration(color: isDark ? AppColors.deepSlate : AppColors.lightBackground, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(15), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(30))),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.lightText)),
                      Text(time, style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniStat(kcal.toStringAsFixed(0), 'kcal', isDark ? Colors.white : AppColors.lightText),
                      const SizedBox(width: 16),
                      _buildMiniStat('${protein.toStringAsFixed(0)}g', 'pro', AppColors.studioIndigo),
                      const SizedBox(width: 16),
                      _buildMiniStat('${fat.toStringAsFixed(0)}g', 'fat', AppColors.vibrantEmerald),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color valueColor) {
    return RichText(
      text: TextSpan(
        text: value,
        style: TextStyle(color: valueColor, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'OpenSans'),
        children: [TextSpan(text: ' $label', style: const TextStyle(color: AppColors.slateMuted, fontWeight: FontWeight.w800, fontSize: 10))],
      ),
    );
  }
}

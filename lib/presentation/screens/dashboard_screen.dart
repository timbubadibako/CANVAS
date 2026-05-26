import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/theme_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _brushAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _brushAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOutQuart)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final bool isDark = themeMode == ThemeMode.dark;
        
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stagger(0, _buildHeader(context, isDark)),
                  const SizedBox(height: 32),
                  _stagger(1, _buildProgressCard(context, isDark)),
                  const SizedBox(height: 40),
                  _stagger(2, _buildRecentLayersHeader(isDark)),
                  const SizedBox(height: 24),
                  _stagger(3, _buildArtisticLogItem(context, 'Garden Palette', 'LUNCH • 320 KCAL', '🥗', AppColors.studioIndigo, isDark)),
                  const SizedBox(height: 16),
                  _stagger(4, _buildArtisticLogItem(context, 'Oatmilk Canvas', 'SNACK • 180 KCAL', '☕', AppColors.vibrantEmerald, isDark)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutQuart));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CANVAS DATE: MAY 26', style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 10
            )),
            const SizedBox(height: 4),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text('Studio Jri', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: isDark ? Colors.white : AppColors.lightText
                )),
                Positioned(
                  bottom: 6,
                  left: -4,
                  child: AnimatedBuilder(
                    animation: _brushAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 14,
                        width: 140 * _brushAnimation.value,
                        decoration: BoxDecoration(
                          color: AppColors.studioIndigo.withValues(alpha: isDark ? 0.25 : 0.15), 
                          borderRadius: BorderRadius.circular(4)
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildOrganicAvatar(isDark),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slateCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NUTRITIONAL COMPOSITION', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 10)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('1,240', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2, color: isDark ? Colors.white : AppColors.lightText)),
              const SizedBox(width: 8),
              Text('/ 2,000 KCAL', style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 32),
          _buildMacroProgress(isDark, 'Protein Base', '98 / 150g', 0.65, AppColors.studioIndigo),
          const SizedBox(height: 20),
          _buildMacroProgress(isDark, 'Energy Carbs', '80 / 200g', 0.40, AppColors.vibrantEmerald),
        ],
      ),
    );
  }

  Widget _buildRecentLayersHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Layers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
        const Text('GALLERY', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildOrganicAvatar(bool isDark) {
    return Container(
      height: 56, width: 56,
      decoration: const BoxDecoration(
        gradient: AppColors.paintGradient,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(35)),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(color: isDark ? AppColors.deepSlate : AppColors.lightBackground, borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(18), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(33))),
        clipBehavior: Clip.antiAlias,
        child: Image.network('https://api.dicebear.com/7.x/avataaars/svg?seed=Felix'),
      ),
    );
  }

  Widget _buildMacroProgress(bool isDark, String label, String value, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.lightText)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress, minHeight: 8, 
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), 
            valueColor: AlwaysStoppedAnimation<Color>(color)
          ),
        ),
      ],
    );
  }

  Widget _buildArtisticLogItem(BuildContext context, String title, String subtitle, String icon, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slateCard.withValues(alpha: 0.7) : AppColors.lightCard, 
        borderRadius: BorderRadius.circular(32), 
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 20),
            Container(
              height: 60, width: 60,
              decoration: BoxDecoration(color: isDark ? AppColors.deepSlate : AppColors.lightBackground, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(15), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(25))),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : AppColors.lightText)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.1)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/meal_diary/meal_diary_bloc.dart';
import '../../data/repositories/food_repository_impl.dart';
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
    
    _loadLogs();
  }

  void _loadLogs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MealDiaryBloc>().add(LoadMealDiaryRequested(
        authState.user.id, 
        filter: _selectedFilter == 'All Layers' ? null : _selectedFilter
      ));
    }
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
        _loadLogs();
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
            child: BlocBuilder<MealDiaryBloc, MealDiaryState>(
              builder: (context, state) {
                if (state is MealDiaryLoading) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stagger(0, _buildHeader(context, isDark)),
                        const SizedBox(height: 40),
                        _buildShimmerLoading(isDark),
                      ],
                    ),
                  );
                }
                
                if (state is MealDiaryFailure) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                // Render structure always, regardless if logs are empty
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stagger(0, _buildHeader(context, isDark)),
                      const SizedBox(height: 40),
                      
                      if (state is MealDiaryLoaded) ...[
                        if (state.logs.isEmpty)
                          _buildEmptyState(isDark)
                        else
                          ..._buildGroupedLogs(state.logs, isDark)
                      ],
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupedLogs(List<FoodLogEntry> logs, bool isDark) {
    Map<String, List<FoodLogEntry>> groupedLogs = {};
    for (var log in logs) {
      String dateKey = DateFormat('yyyy-MM-dd').format(log.createdAt);
      if (!groupedLogs.containsKey(dateKey)) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(log);
    }

    return groupedLogs.entries.expand((entry) {
      int groupIndex = groupedLogs.keys.toList().indexOf(entry.key);
      DateTime date = DateTime.parse(entry.key);
      String label = DateFormat('EEEE, MMM d').format(date);
      if (DateFormat('yyyy-MM-dd').format(DateTime.now()) == entry.key) {
        label = "Today";
      }

      return [
        _stagger(1 + groupIndex, _buildDateSection(context, label, isFirst: label == "Today", isDark: isDark)),
        const SizedBox(height: 16),
        ...entry.value.map((log) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _stagger(2 + groupIndex, _buildDiaryItem(context, log, isDark)),
        )),
        const SizedBox(height: 16),
      ];
    }).toList();
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Column(
      children: List.generate(5, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
          child: Container(
            height: 120, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
          ),
        ),
      )),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.layers, size: 64, color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 24),
          Text('NO LOGS FOUND', style: TextStyle(color: AppColors.slateMuted, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('Your canvas is still empty for this layer.', 
            style: TextStyle(color: AppColors.slateMuted.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutQuart));
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

  Widget _buildDiaryItem(BuildContext context, FoodLogEntry log, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              title: log.foodName,
              time: DateFormat('HH:mm').format(log.createdAt),
              icon: "🖼️",
              kcal: log.caloriesKcal,
              protein: log.proteinG,
              carbs: log.carbsG,
              fat: log.fatG,
              imageUrl: log.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
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
              child: const Center(child: Text("🖼️", style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(log.foodName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.lightText)),
                      Text(DateFormat('HH:mm').format(log.createdAt), style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniStat(log.caloriesKcal.toStringAsFixed(0), 'kcal', isDark ? Colors.white : AppColors.lightText),
                      const SizedBox(width: 16),
                      _buildMiniStat('${log.proteinG.toStringAsFixed(0)}g', 'pro', AppColors.studioIndigo),
                      const SizedBox(width: 16),
                      _buildMiniStat('${log.fatG.toStringAsFixed(0)}g', 'fat', AppColors.vibrantEmerald),
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

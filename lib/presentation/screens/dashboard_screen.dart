import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../../data/repositories/food_repository_impl.dart';
import 'meal_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const DashboardScreen({super.key, required this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _brushAnimation;
  
  final FoodRepository _foodRepo = FoodRepositoryImpl();
  List<FoodLogEntry> _todayLogs = [];
  List<FoodLogEntry> _recentLogs = [];
  bool _isLoadingLogs = true;

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

    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // PRE-FETCHING DATA IN PARALLEL 🚀
      await Future.wait([
        Future.microtask(() => context.read<ProfileBloc>().add(LoadProfileRequested(authState.user.id))),
        _foodRepo.getTodayLogs(authState.user.id).then((logs) {
          if (mounted) setState(() { _todayLogs = logs; });
        }),
        _foodRepo.getRecentLogs(authState.user.id, limit: 3).then((logs) {
          if (mounted) setState(() { 
            _recentLogs = logs; 
            _isLoadingLogs = false; 
          });
        }),
      ]);
    }
  }

  double get _consumedKcal => _todayLogs.fold(0.0, (sum, item) => sum + item.caloriesKcal);
  double get _consumedProtein => _todayLogs.fold(0.0, (sum, item) => sum + item.proteinG);
  double get _consumedCarbs => _todayLogs.fold(0.0, (sum, item) => sum + item.carbsG);

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
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stagger(0, _buildHeader(context, isDark, profileState)),
                      const SizedBox(height: 32),
                      _stagger(1, _buildProgressCard(context, isDark, profileState)),
                      const SizedBox(height: 40),
                      _stagger(2, _buildRecentLayersHeader(isDark)),
                      const SizedBox(height: 24),
                      
                      if (_isLoadingLogs)
                        _buildShimmerLoading(isDark)
                      else if (_recentLogs.isEmpty)
                        _buildEmptyState(isDark)
                      else
                        ..._recentLogs.asMap().entries.map((entry) {
                          final log = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _stagger(3 + entry.key, _buildArtisticLogItem(context, log, isDark)),
                          );
                        }),
                      
                      const SizedBox(height: 100),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(LucideIcons.palette, color: isDark ? Colors.white10 : Colors.black12, size: 48),
          const SizedBox(height: 16),
          Text('NO MASTERPIECE PAINTED YET', 
            style: TextStyle(color: AppColors.slateMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ],
      ),
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

  Widget _buildHeader(BuildContext context, bool isDark, ProfileState profileState) {
    String name = "";
    String? avatar;
    final String todayDate = DateFormat('MMMM dd').format(DateTime.now()).toUpperCase();

    if (profileState is ProfileLoaded) {
      name = profileState.profile.fullName;
      avatar = profileState.profile.avatarUrl;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CANVAS DATE: $todayDate', style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontSize: 10
            )),
            const SizedBox(height: 4),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                        width: (name.length * 12.0) * _brushAnimation.value,
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
        GestureDetector(
          onTap: () => widget.onNavigateToTab(4), // Go to Profile
          child: _buildOrganicAvatar(isDark, avatar),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
          child: Container(
            height: 100, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          ),
        ),
      )),
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isDark, ProfileState profileState) {
    if (profileState is ProfileLoading) {
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
        child: Container(
          height: 280, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(48)),
        ),
      );
    }
    
    int targetKcal = 2000;
    double proTarget = 150;
    double carbTarget = 200;

    if (profileState is ProfileLoaded) {
      targetKcal = profileState.profile.dailyCalorieTarget;
      proTarget = profileState.profile.dailyProteinTarget ?? 150;
      carbTarget = profileState.profile.dailyCarbsTarget ?? 200;
    }

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
              Text('${_consumedKcal.toInt()}', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2, color: isDark ? Colors.white : AppColors.lightText)),
              const SizedBox(width: 8),
              Text('/ $targetKcal KCAL', style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 32),
          _buildMacroProgress(isDark, 'Protein Base', '${_consumedProtein.toInt()} / ${proTarget.toInt()}g', _consumedProtein/proTarget, AppColors.studioIndigo),
          const SizedBox(height: 20),
          _buildMacroProgress(isDark, 'Energy Carbs', '${_consumedCarbs.toInt()} / ${carbTarget.toInt()}g', _consumedCarbs/carbTarget, AppColors.vibrantEmerald),
        ],
      ),
    );
  }

  Widget _buildRecentLayersHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Layers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
        GestureDetector(
          onTap: () => widget.onNavigateToTab(1), // Go to Diary
          child: const Text('GALLERY', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
        ),
      ],
    );
  }

  Widget _buildOrganicAvatar(bool isDark, String? imageUrl) {
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
        child: imageUrl != null 
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : const Icon(LucideIcons.user, color: Colors.white24),
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
            value: progress.clamp(0, 1), minHeight: 8, 
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), 
            valueColor: AlwaysStoppedAnimation<Color>(color)
          ),
        ),
      ],
    );
  }

  Widget _buildArtisticLogItem(BuildContext context, FoodLogEntry log, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailScreen(
          title: log.foodName,
          time: "${log.createdAt.hour}:${log.createdAt.minute}",
          icon: "🍽️",
          kcal: log.caloriesKcal,
          protein: log.proteinG,
          carbs: log.carbsG,
          fat: log.fatG,
          imageUrl: log.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
        )));
      },
      child: Container(
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
              Container(width: 4, decoration: BoxDecoration(color: AppColors.studioIndigo, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 20),
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(color: isDark ? AppColors.deepSlate : AppColors.lightBackground, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(15), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(25))),
                child: Center(child: Text("!!", style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.foodName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : AppColors.lightText)),
                    const SizedBox(height: 4),
                    Text("${log.caloriesKcal.toInt()} KCAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.1)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

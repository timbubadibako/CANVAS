import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../data/datasources/gemini_client.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/auth/auth_bloc.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FoodRepository _foodRepo = FoodRepositoryImpl();
  
  List<FoodLogEntry> _allLogs = [];
  String _aiInsight = "Analyzing your masterpiece...";
  bool _isGeneratingInsight = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _controller.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final logs = await _foodRepo.getRecentLogs(authState.user.id, limit: 100);
      if (mounted) {
        setState(() {
          _allLogs = logs;
        });
        _generateAIInsight();
      }
    }
  }

  Future<void> _generateAIInsight() async {
    if (_isGeneratingInsight) return;
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = prefs.getString('last_insight_date');
    final cachedInsight = prefs.getString('cached_insight');

    // Jika hari ini sudah ada insight, gunakan yang lama (Sekali Sehari)
    if (lastDate == today && cachedInsight != null) {
      if (mounted) {
        setState(() {
          _aiInsight = cachedInsight;
        });
      }
      return;
    }

    // Jika ganti hari, minta AI generate baru
    setState(() => _isGeneratingInsight = true);

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final p = profileState.profile;
      final bmi = (p.weightKg ?? 70) / (((p.heightCm ?? 170) / 100) * ((p.heightCm ?? 170) / 100));
      
      final dataContext = "Today: ${_todayKcal.toInt()}/${p.dailyCalorieTarget} kcal. Pro: ${_todayProtein.toInt()}g. BMI: ${bmi.toStringAsFixed(1)}. Strategy: ${p.fitnessStrategy}.";
      
      final insight = await GeminiClient().getStudioInsight(dataContext);
      
      // Simpan ke Cache Lokal
      await prefs.setString('last_insight_date', today);
      await prefs.setString('cached_insight', insight);

      if (mounted) {
        setState(() {
          _aiInsight = insight;
          _isGeneratingInsight = false;
        });
      }
    }
  }

  double get _todayKcal => _getKcalForDate(DateTime.now());
  double get _todayProtein => _getProteinForDate(DateTime.now());
  double get _todayCarbs => _getCarbsForDate(DateTime.now());
  double get _todayFat => _getFatForDate(DateTime.now());

  double _getKcalForDate(DateTime date) {
    final dString = DateFormat('yyyy-MM-dd').format(date);
    return _allLogs
        .where((log) => DateFormat('yyyy-MM-dd').format(log.createdAt) == dString)
        .fold(0, (sum, item) => sum + item.caloriesKcal);
  }

  double _getProteinForDate(DateTime date) {
    final dString = DateFormat('yyyy-MM-dd').format(date);
    return _allLogs
        .where((log) => DateFormat('yyyy-MM-dd').format(log.createdAt) == dString)
        .fold(0, (sum, item) => sum + item.proteinG);
  }

  double _getCarbsForDate(DateTime date) {
    final dString = DateFormat('yyyy-MM-dd').format(date);
    return _allLogs
        .where((log) => DateFormat('yyyy-MM-dd').format(log.createdAt) == dString)
        .fold(0, (sum, item) => sum + item.carbsG);
  }

  double _getFatForDate(DateTime date) {
    final dString = DateFormat('yyyy-MM-dd').format(date);
    return _allLogs
        .where((log) => DateFormat('yyyy-MM-dd').format(log.createdAt) == dString)
        .fold(0, (sum, item) => sum + item.fatG);
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
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                return RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.studioIndigo,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stagger(0, _buildHeader(context, isDark)),
                        const SizedBox(height: 32),
                        _stagger(1, _buildMainChartCard(context, isDark, profileState)),
                        const SizedBox(height: 32),
                        
                        _stagger(2, _buildSectionTitle('Weight Canvas', isDark)),
                        const SizedBox(height: 16),
                        _stagger(3, _buildBMICard(isDark, profileState)),
                        
                        const SizedBox(height: 32),
                        
                        _stagger(4, _buildSectionTitle('Nutritional Balance', isDark)),
                        const SizedBox(height: 16),
                        _stagger(5, _buildMacroDistribution(isDark, profileState)),
                        
                        const SizedBox(height: 32),
                        _stagger(6, _buildInsightCard(isDark)),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title.toUpperCase(), 
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? AppColors.slateMuted : AppColors.lightMuted));
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: 'Studio ',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isDark ? Colors.white : AppColors.lightText),
            children: const [TextSpan(text: 'Analytics', style: TextStyle(color: AppColors.studioIndigo))],
          ),
        ),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(LucideIcons.refreshCw, color: AppColors.studioIndigo, size: 20),
        ),
      ],
    );
  }

  Widget _buildMainChartCard(BuildContext context, bool isDark, ProfileState profileState) {
    int targetKcal = 2000;
    if (profileState is ProfileLoaded) {
      targetKcal = profileState.profile.dailyCalorieTarget;
    }

    final now = DateTime.now();
    final last7Days = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard : AppColors.lightCard, borderRadius: BorderRadius.circular(48), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)), boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('WEEKLY KCAL TREND', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 10)),
        const SizedBox(height: 32),
        SizedBox(
          height: 120, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: last7Days.map((date) {
              double consumed = _getKcalForDate(date);
              double percent = (consumed / targetKcal).clamp(0, 1.2); 
              bool isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(now);
              return _buildBar(percent, DateFormat('E').format(date), isHighlight: isToday, isDark: isDark);
            }).toList(),
          )
        ),
      ]),
    );
  }

  Widget _buildBar(double percent, String label, {bool isHighlight = false, required bool isDark}) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      AnimatedBuilder(
        animation: _controller, 
        builder: (context, child) => Container(
          width: 16, 
          height: (100 * percent * _controller.value).clamp(4.0, 100.0), 
          decoration: BoxDecoration(
            gradient: isHighlight ? AppColors.paintGradient : null, 
            color: isHighlight ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)), 
            borderRadius: BorderRadius.circular(10)
          )
        )
      ),
      const SizedBox(height: 12),
      Text(label, style: TextStyle(fontSize: 9, fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold, color: isHighlight ? AppColors.studioIndigo : (isDark ? AppColors.slateMuted : AppColors.lightMuted))),
    ]);
  }

  Widget _buildBMICard(bool isDark, ProfileState profileState) {
    double weight = 70.0;
    double heightCm = 170.0;
    if (profileState is ProfileLoaded) {
      weight = profileState.profile.weightKg ?? 70.0;
      heightCm = profileState.profile.heightCm?.toDouble() ?? 170.0;
    }

    double bmi = weight / ((heightCm / 100) * (heightCm / 100));
    String status = "Healthy";
    Color statusColor = AppColors.vibrantEmerald;

    if (bmi < 18.5) { status = "Underweight"; statusColor = AppColors.energyOrange; }
    else if (bmi >= 25 && bmi < 30) { status = "Overweight"; statusColor = AppColors.energyOrange; }
    else if (bmi >= 30) { status = "Obese"; statusColor = AppColors.deepRose; }

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard : AppColors.lightCard, borderRadius: BorderRadius.circular(40), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.indigo.withValues(alpha: 0.05))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BODY MASS INDEX', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.1)),
            const SizedBox(height: 4),
            Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
            child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ),
        ]),
        const SizedBox(height: 20),
        _buildBMIScale(bmi, isDark),
        const SizedBox(height: 20),
        Text('${weight.toStringAsFixed(1)} KG / ${heightCm.toInt()} CM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slateMuted)),
      ]),
    );
  }

  Widget _buildBMIScale(double bmi, bool isDark) {
    double position = (bmi - 15) / (35 - 15); 
    position = position.clamp(0, 1);

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 6, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.green, Colors.orange, Colors.red]),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              alignment: Alignment(position * 2 - 1, 0),
              child: Container(
                height: 14, width: 4,
                decoration: BoxDecoration(color: isDark ? Colors.white : Colors.black, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroDistribution(bool isDark, ProfileState profileState) {
    double targetKcal = 2000;
    double targetPro = 150;
    double targetCarb = 200;
    double targetFat = 65;

    if (profileState is ProfileLoaded) {
      targetKcal = profileState.profile.dailyCalorieTarget.toDouble();
      targetPro = profileState.profile.dailyProteinTarget ?? 150;
      targetCarb = profileState.profile.dailyCarbsTarget ?? 200;
      targetFat = profileState.profile.dailyFatTarget ?? 65;
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard.withValues(alpha: 0.7) : AppColors.lightCard, borderRadius: BorderRadius.circular(40)),
      child: Column(
        children: [
          _buildDetailRow("Daily Calories", _todayKcal, targetKcal, "kcal", AppColors.studioIndigo, isDark),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircleStat('Pro', _todayProtein, targetPro, AppColors.studioIndigo, isDark),
              _buildCircleStat('Carb', _todayCarbs, targetCarb, AppColors.energyOrange, isDark),
              _buildCircleStat('Fat', _todayFat, targetFat, AppColors.deepRose, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double current, double target, String unit, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            RichText(
              text: TextSpan(
                text: '${current.toInt()}',
                style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16),
                children: [
                  TextSpan(text: ' / ${target.toInt()} $unit', style: const TextStyle(fontSize: 12, color: AppColors.slateMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (current / target).clamp(0, 1.2),
            minHeight: 6,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleStat(String label, double current, double target, Color color, bool isDark) {
    final double percent = (current / target).clamp(0, 1.2);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 72, width: 72,
              child: CircularProgressIndicator(
                value: percent > 1 ? 1 : percent, 
                strokeWidth: 8, strokeCap: StrokeCap.round,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
          ],
        ),
        const SizedBox(height: 12),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted)),
        const SizedBox(height: 4),
        Text('${current.toInt()}/${target.toInt()}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.slateMuted)),
      ],
    );
  }

  Widget _buildInsightCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03), Colors.transparent]), borderRadius: BorderRadius.circular(32)),
      child: Row(children: [
        const Icon(LucideIcons.sparkles, color: AppColors.energyOrange, size: 24),
        const SizedBox(width: 16),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(_aiInsight, 
            key: ValueKey<String>(_aiInsight),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slateMuted)
          ),
        )),
      ]),
    );
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.5).clamp(0, 1), curve: Curves.easeOutQuart));
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child));
  }
}

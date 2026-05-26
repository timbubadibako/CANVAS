import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stagger(0, Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Studio ',
                      style: Theme.of(context).textTheme.headlineMedium,
                      children: const [TextSpan(text: 'Analytics', style: TextStyle(color: AppColors.studioIndigo))],
                    ),
                  ),
                  const Icon(LucideIcons.share2, color: AppColors.slateMuted, size: 20),
                ],
              )),
              const SizedBox(height: 32),
              _stagger(1, _buildMainChartCard(context)),
              const SizedBox(height: 32),
              _stagger(2, Text('Nutritional Balance'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.slateMuted))),
              const SizedBox(height: 16),
              _stagger(3, _buildMacroDistribution()),
              const SizedBox(height: 32),
              _stagger(4, _buildInsightCard()),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, (index * 0.1 + 0.5).clamp(0, 1), curve: Curves.easeOutQuart));
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child));
  }

  Widget _buildMainChartCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WEEKLY KCAL TREND', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 10)),
              Text('AVG: 1,840', style: TextStyle(color: AppColors.slateMuted, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.4, 'Mon'),
                _buildBar(0.7, 'Tue'),
                _buildBar(0.9, 'Wed', isHighlight: true),
                _buildBar(0.3, 'Thu'),
                _buildBar(0.5, 'Fri'),
                _buildBar(0.8, 'Sat'),
                _buildBar(0.6, 'Sun'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 16,
              height: 120 * height * _controller.value,
              decoration: BoxDecoration(
                gradient: isHighlight ? AppColors.paintGradient : null,
                color: isHighlight ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isHighlight ? [BoxShadow(color: AppColors.studioIndigo.withValues(alpha: 0.3), blurRadius: 15)] : null,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.slateMuted)),
      ],
    );
  }

  Widget _buildMacroDistribution() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.slateCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircleStat('Pro', 0.65, AppColors.studioIndigo),
          _buildCircleStat('Carb', 0.40, AppColors.energyOrange),
          _buildCircleStat('Fat', 0.85, AppColors.deepRose),
        ],
      ),
    );
  }

  Widget _buildCircleStat(String label, double val, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 64, width: 64,
              child: CircularProgressIndicator(
                value: val,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${(val * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.1)),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.05), Colors.transparent]),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: AppColors.energyOrange, size: 24),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "You're leaning into a high-protein palette today. Excellent for muscle repair.",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slateMuted),
            ),
          ),
        ],
      ),
    );
  }
}

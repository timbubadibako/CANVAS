import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/theme_cubit.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Weight State
  double _currentWeight = 72.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showWeightLogger() {
    final weightCtrl = TextEditingController(text: _currentWeight.toString());
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 32),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(48))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 32),
          const Text('LOG DAILY WEIGHT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: AppColors.studioIndigo)),
          const SizedBox(height: 24),
          TextField(
            controller: weightCtrl, keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              suffixText: 'KG', suffixStyle: const TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.bold),
              filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(onPressed: () { setState(() => _currentWeight = double.tryParse(weightCtrl.text) ?? _currentWeight); Navigator.pop(context); StudioToast.show(context, 'WEIGHT CANVAS UPDATED', icon: LucideIcons.scale); }, child: const Text('SAVE PROGRESS')),
          const SizedBox(height: 40),
        ]),
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
                  _stagger(0, Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Studio ',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isDark ? Colors.white : AppColors.lightText),
                          children: const [TextSpan(text: 'Analytics', style: TextStyle(color: AppColors.studioIndigo))],
                        ),
                      ),
                      Icon(LucideIcons.share2, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, size: 20),
                    ],
                  )),
                  const SizedBox(height: 32),
                  _stagger(1, _buildMainChartCard(context, isDark)),
                  const SizedBox(height: 32),
                  
                  // --- Weight Canvas Section ---
                  _stagger(2, Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weight Canvas'.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? AppColors.slateMuted : AppColors.lightMuted)),
                      GestureDetector(
                        onTap: _showWeightLogger,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.studioIndigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.studioIndigo.withValues(alpha: 0.2))),
                          child: Row(children: [const Icon(LucideIcons.plus, size: 12, color: AppColors.studioIndigo), const SizedBox(width: 4), Text('LOG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.studioIndigo))]),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  _stagger(3, _buildWeightTrendCard(isDark)),
                  
                  const SizedBox(height: 32),
                  _stagger(4, Text('Nutritional Balance'.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? AppColors.slateMuted : AppColors.lightMuted))),
                  const SizedBox(height: 16),
                  _stagger(5, _buildMacroDistribution(isDark)),
                  const SizedBox(height: 32),
                  _stagger(6, _buildInsightCard(isDark)),
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

  Widget _buildMainChartCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard : AppColors.lightCard, borderRadius: BorderRadius.circular(48), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05)), boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('WEEKLY KCAL TREND', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 10)),
          Text('AVG: 1,840', style: TextStyle(color: isDark ? AppColors.slateMuted : AppColors.lightMuted, fontWeight: FontWeight.bold, fontSize: 10)),
        ]),
        const SizedBox(height: 32),
        SizedBox(height: 120, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildBar(0.4, 'Mon', isDark: isDark), _buildBar(0.7, 'Tue', isDark: isDark), _buildBar(0.9, 'Wed', isHighlight: true, isDark: isDark), _buildBar(0.3, 'Thu', isDark: isDark), _buildBar(0.5, 'Fri', isDark: isDark), _buildBar(0.8, 'Sat', isDark: isDark), _buildBar(0.6, 'Sun', isDark: isDark),
        ])),
      ]),
    );
  }

  Widget _buildBar(double height, String label, {bool isHighlight = false, required bool isDark}) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      AnimatedBuilder(animation: _controller, builder: (context, child) => Container(width: 16, height: 100 * height * _controller.value, decoration: BoxDecoration(gradient: isHighlight ? AppColors.paintGradient : null, color: isHighlight ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)), borderRadius: BorderRadius.circular(10), boxShadow: isHighlight ? [BoxShadow(color: AppColors.studioIndigo.withValues(alpha: 0.3), blurRadius: 15)] : null))),
      const SizedBox(height: 12),
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? AppColors.slateMuted : AppColors.lightMuted)),
    ]);
  }

  Widget _buildWeightTrendCard(bool isDark) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard : AppColors.lightCard, borderRadius: BorderRadius.circular(40), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.indigo.withValues(alpha: 0.05)), boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CURRENT WEIGHT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.1)),
            const SizedBox(height: 4),
            Text('$_currentWeight KG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('MONTHLY CHANGE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.slateMuted, letterSpacing: 1.1)),
            const SizedBox(height: 4),
            Text('-1.2 KG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.vibrantEmerald)),
          ]),
        ]),
        const SizedBox(height: 24),
        // Simple Dummy Line Chart Visualization
        SizedBox(height: 60, width: double.infinity, child: CustomPaint(painter: _SimpleLinePainter(isDark: isDark))),
      ]),
    );
  }

  Widget _buildMacroDistribution(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: isDark ? AppColors.slateCard.withValues(alpha: 0.7) : AppColors.lightCard, borderRadius: BorderRadius.circular(40), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.indigo.withValues(alpha: 0.05)), boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildCircleStat('Pro', 0.65, AppColors.studioIndigo, isDark), _buildCircleStat('Carb', 0.40, AppColors.energyOrange, isDark), _buildCircleStat('Fat', 0.85, AppColors.deepRose, isDark),
      ]),
    );
  }

  Widget _buildCircleStat(String label, double val, Color color, bool isDark) {
    return Column(children: [
      Stack(alignment: Alignment.center, children: [
        SizedBox(height: 64, width: 64, child: CircularProgressIndicator(value: val, strokeWidth: 8, strokeCap: StrokeCap.round, backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation<Color>(color))),
        Text('${(val * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.lightText)),
      ]),
      const SizedBox(height: 12),
      Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? AppColors.slateMuted : AppColors.lightMuted, letterSpacing: 1.1)),
    ]);
  }

  Widget _buildInsightCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03), Colors.transparent]), borderRadius: BorderRadius.circular(32), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05))),
      child: Row(children: [
        const Icon(LucideIcons.sparkles, color: AppColors.energyOrange, size: 24),
        const SizedBox(width: 16),
        Expanded(child: Text("You're leaning into a high-protein palette today. Excellent for muscle repair.", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.slateMuted : AppColors.lightMuted))),
      ]),
    );
  }
}

class _SimpleLinePainter extends CustomPainter {
  final bool isDark;
  _SimpleLinePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.studioIndigo..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.4, size.width * 0.4, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../screens/dashboard_screen.dart';
import '../screens/meal_diary_screen.dart';
import '../screens/ai_scanner_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({super.key});

  @override
  State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  void _setIndex(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isScannerActive = _currentIndex == 2;

    final List<Widget> screens = [
      const DashboardScreen(),
      const MealDiaryScreen(),
      AIScannerScreen(onBackToHome: () => _setIndex(_previousIndex)), // Smart Back Logic
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_currentIndex],
      bottomNavigationBar: isScannerActive 
          ? const SizedBox.shrink() 
          : Container(
              margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.deepSlate.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, LucideIcons.home, 'Home'),
                  _buildNavItem(1, LucideIcons.layers, 'Diary'),
                  _buildFab(),
                  _buildNavItem(3, LucideIcons.barChart2, 'Stats'),
                  _buildNavItem(4, LucideIcons.user, 'Profile'),
                ],
              ),
            ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppColors.studioIndigo : AppColors.slateMuted,
          ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              height: 4, width: 4,
              decoration: const BoxDecoration(color: AppColors.studioIndigo, shape: BoxShape.circle),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: GestureDetector(
        onTap: () => _setIndex(2),
        child: Container(
          height: 72, width: 72,
          decoration: BoxDecoration(
            gradient: AppColors.paintGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.studioIndigo.withValues(alpha: 0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: AppColors.deepSlate, width: 6),
          ),
          child: const Icon(LucideIcons.camera, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

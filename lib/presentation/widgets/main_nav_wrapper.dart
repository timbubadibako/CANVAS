import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import '../../data/datasources/gemini_client.dart';
import '../screens/dashboard_screen.dart';
import '../screens/meal_diary_screen.dart';
import '../screens/ai_scanner_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/profile/profile_bloc.dart';
import '../../core/utils/bot_prompt_decorator.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({super.key});

  @override
  State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;

  // Bot Animation Controllers
  late AnimationController _shakeController;
  late AnimationController _chatRoomController;
  bool _hasNotification = true;
  bool _isChatOpen = false;
  bool _isBotThinking = false;
  String? _activeReminder;

  // Chat Data
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello Artist! How can I help with your masterpiece today?',
      'isBot': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chatRoomController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        _triggerBotNotification("Don't forget to paint your Lunch log!");
    });
  }

  void _triggerBotNotification(String message) {
    setState(() {
      _hasNotification = true;
      _activeReminder = message;
    });
    _shakeController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _activeReminder != null)
        setState(() => _activeReminder = null);
    });
  }

  void _onBotPressed() {
    if (_hasNotification) {
      setState(() {
        _hasNotification = false;
        _shakeController.stop();
        _shakeController.reset();
        _activeReminder = _activeReminder == null
            ? "I'm ready for your questions!"
            : null;
      });
    } else if (_isChatOpen) {
      _sendMessage();
    } else {
      setState(() {
        _isChatOpen = true;
        _chatRoomController.forward();
      });
    }
  }

  void _sendMessage() async {
    if (_chatController.text.isEmpty) return;
    final rawUserText = _chatController.text;

    // 1. Ambil profile dari Bloc (misal state-nya loaded)
    final profileState = context.read<ProfileBloc>().state;
    String finalPrompt = rawUserText;
  
    if (profileState is ProfileLoaded) {
    // 2. Bungkus pesan dengan konteks gizi
    finalPrompt = BotPromptDecorator.decorate(rawUserText, profileState.profile);
    }
  
    // 3. Kirim prompt yang sudah kaya data ke Gemini

    setState(() {
      _messages.add({'text': rawUserText, 'isBot': false});
      _chatController.clear();
      _isBotThinking = true;
    });

    
    try {
      final response = await GeminiClient().getChatResponse(finalPrompt);
      if (mounted) {
        setState(() {
          _isBotThinking = false;
          _messages.add({'text': response, 'isBot': true});
        });
      }
    } catch (e) {
      print("[StudioBot] Gemini API Error: $e"); // Log error detail
      if (mounted) {
        setState(() => _isBotThinking = false);
        StudioToast.show(
          context,
          'STUDIO OFFLINE: $e',
          icon: LucideIcons.wifiOff,
        );
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _chatRoomController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _setIndex(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final bool isDark = themeMode == ThemeMode.dark;
        final bool isScannerActive = _currentIndex == 2;

        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final bool isKeyboardOpen = keyboardHeight > 0;
        final double botBottomPos = isKeyboardOpen
            ? (keyboardHeight + 12)
            : 128;

        final List<Widget> screens = [
          DashboardScreen(onNavigateToTab: _setIndex),
          const MealDiaryScreen(),
          AIScannerScreen(onBackToHome: () => _setIndex(_previousIndex)),
          const StatsScreen(),
          const ProfileScreen(),
        ];

        return PopScope(
          canPop: _currentIndex == 0 && !_isChatOpen,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_isChatOpen) {
              setState(() {
                _isChatOpen = false;
                _chatRoomController.reverse();
              });
            } else if (_currentIndex != 0) {
              _setIndex(0);
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBody: true,
            body: Stack(
              children: [
                screens[_currentIndex],
                if (!isScannerActive) ...[
                  _buildChatOverlay(isDark, botBottomPos),
                  if (_activeReminder != null)
                    _buildReminderBubble(isDark, botBottomPos),
                  _buildFloatingBot(isDark, botBottomPos),
                ],
              ],
            ),
            bottomNavigationBar: isScannerActive
                ? const SizedBox.shrink()
                : _buildBottomNav(isDark),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBot(bool isDark, double bottomPos) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuart,
      bottom: bottomPos+12,
      right: 32,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final double shake = _hasNotification
              ? math.sin(_shakeController.value * math.pi * 2) * 2
              : 0;
          final double rotate = _hasNotification
              ? math.sin(_shakeController.value * math.pi * 2) * 0.05
              : 0;
          return Transform.translate(
            offset: Offset(shake, shake / 4),
            child: Transform.rotate(
              angle: rotate,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _onBotPressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.emeraldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vibrantEmerald.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? AppColors.vibrantEmerald
                              : Colors.white,
                          width: 1,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          _isChatOpen ? LucideIcons.send : LucideIcons.bot,
                          key: ValueKey<bool>(_isChatOpen),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  if (_hasNotification && !_isChatOpen)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: AppColors.deepRose,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.deepSlate : Colors.white,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderBubble(bool isDark, double botBottomPos) {
    if (_isChatOpen) return const SizedBox.shrink();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: botBottomPos + 76,
      right: 28,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: value.clamp(0.0, 1.0),
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slateCard : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Text(
                  _activeReminder!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatOverlay(bool isDark, double bottomPos) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: bottomPos,
      right: 28,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _chatRoomController,
          curve: Curves.easeOut,
        ),
        alignment: Alignment.bottomRight,
        child: FadeTransition(
          opacity: _chatRoomController,
          child: Container(
            width: MediaQuery.of(context).size.width - 64,
            height: 592,
            decoration: BoxDecoration(
              color: isDark ? AppColors.deepSlate : Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.vibrantEmerald.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.bot,
                        color: AppColors.vibrantEmerald,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'STUDIO ASSISTANT',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isChatOpen = false;
                            _chatRoomController.reverse();
                          });
                        },
                        icon: const Icon(LucideIcons.x, size: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _messages.length + (_isBotThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isBotThinking) {
                        return _buildThinkingBubble(isDark);
                      }
                      final msg = _messages[index];
                      return _buildChatBubble(
                        msg['text'],
                        msg['isBot'],
                        isDark,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _chatController,
                    maxLines: 5,
                    minLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask the Studio...',
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 20,
                        top: 14,
                        bottom: 14,
                        right: 32,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isBot, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot
                    ? (isDark
                          ? AppColors.slateCard
                          : Colors.black.withValues(alpha: 0.05))
                    : AppColors.vibrantEmerald,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isBot ? 4 : 20),
                  bottomRight: Radius.circular(isBot ? 20 : 4),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isBot
                      ? (isDark ? Colors.white : AppColors.lightText)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.slateCard
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      height: 84,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.deepSlate : Colors.white).withValues(
          alpha: 0.95,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.indigo.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildExpandedNavItem(0, LucideIcons.home, 'Home', isDark),
          _buildExpandedNavItem(1, LucideIcons.layers, 'Diary', isDark),
          _buildFab(isDark),
          _buildExpandedNavItem(3, LucideIcons.barChart2, 'Stats', isDark),
          _buildExpandedNavItem(4, LucideIcons.user, 'Profile', isDark),
        ],
      ),
    );
  }

  Widget _buildExpandedNavItem(
    int index,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final bool isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 24,
                color: isActive
                    ? AppColors.studioIndigo
                    : (isDark ? AppColors.slateMuted : AppColors.lightMuted),
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 6),
              Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: AppColors.studioIndigo,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFab(bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: GestureDetector(
        onTap: () => _setIndex(2),
        child: Container(
          height: 72,
          width: 72,
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
            border: Border.all(
              color: isDark ? AppColors.deepSlate : Colors.white,
              width: 6,
            ),
          ),
          child: const Icon(LucideIcons.camera, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

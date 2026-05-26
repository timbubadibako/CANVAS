import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
    setState(() => _currentPage = 1);
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
    setState(() => _currentPage = 0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0, // Hanya bisa pop (keluar) jika di halaman Login
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentPage == 1) {
          _previousPage(); // Jika di Register, balik ke Login dulu
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            LoginScreen(onSignUpPressed: _nextPage),
            RegisterScreen(onBackPressed: _previousPage),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/bloc/theme_cubit.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => ThemeCubit(),
      child: const CanvasApp(),
    ),
  );
}

class CanvasApp extends StatelessWidget {
  const CanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'CANVAS Studio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AuthScreen(),
        );
      },
    );
  }
}

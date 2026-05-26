import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/widgets/main_nav_wrapper.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/datasources/gemini_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Inisialisasi Otak AI
  GeminiClient().init();

  final authRepository = AuthRepositoryImpl();
  final profileRepository = ProfileRepositoryImpl();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => AuthBloc(authRepository)..add(AuthCheckRequested())),
        BlocProvider(create: (context) => ProfileBloc(profileRepository)),
      ],
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
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return const MainNavWrapper();
              } else if (authState is AuthLoading || authState is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}

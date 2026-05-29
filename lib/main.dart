import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/main_nav_wrapper.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/meal_diary/meal_diary_bloc.dart';
import 'presentation/bloc/scanner/scanner_bloc.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/food_repository_impl.dart';
import 'data/services/cloud_inference_service.dart';
import 'data/services/local_onnx_service.dart';
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
  final foodRepository = FoodRepositoryImpl();
  final cloudInference = CloudInferenceService();
  final localInference = LocalOnnxService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => AuthBloc(authRepository, profileRepository)..add(AuthCheckRequested())),
        BlocProvider(create: (context) => ProfileBloc(profileRepository)),
        BlocProvider(create: (context) => MealDiaryBloc(foodRepository)),
        BlocProvider(create: (context) => ScannerBloc(cloudService: cloudInference, localService: localInference)),
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
          home: const RootRouter(),
        );
      },
    );
  }
}

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplash();
  }

  void _hideSplash() async {
    // Tampilkan Splash Screen minimal 3 detik untuk vibransi artistik
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _showSplash 
        ? const SplashScreen(key: ValueKey('splash'))
        : BlocBuilder<AuthBloc, AuthState>(
            key: const ValueKey('auth_router'),
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                if (authState.isNewUser) {
                  return const OnboardingPreferencesScreen();
                }
                return const MainNavWrapper();
              } else if (authState is AuthLoading || authState is AuthInitial) {
                return const SplashScreen(key: ValueKey('splash_loading'));
              }
              return const AuthScreen();
            },
          ),
    );
  }
}

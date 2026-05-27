import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/profile_repository.dart';

// --- Events ---
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  AuthSignUpRequested(this.email, this.password, this.fullName);
}

class AuthSignOutRequested extends AuthEvent {}

class AuthOnboardingCompleted extends AuthEvent {}

// --- States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isNewUser;
  AuthAuthenticated(this.user, {this.isNewUser = false});
}

class AuthUnauthenticated extends AuthState {
  final String? prefilledEmail;
  final String? prefilledPassword;
  AuthUnauthenticated({this.prefilledEmail, this.prefilledPassword});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  AuthBloc(this._authRepository, this._profileRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      final user = _authRepository.currentUser;
      if (user != null) {
        try {
          print('[AuthBloc] Checking profile for user: ${user.id}');
          final profile = await _profileRepository.getProfile(user.id);
          bool isNew = profile.dailyCalorieTarget == 0 || 
                       profile.primaryGoal == null || 
                       profile.primaryGoal!.isEmpty;
          
          print('[AuthBloc] Profile found. isNewUser: $isNew');
          emit(AuthAuthenticated(user, isNewUser: isNew));
        } catch (e) {
          print('[AuthBloc] Profile fetch failed: $e. Destroying session for safety.');
          await _authRepository.signOut(); // PAKSA DESTROY SESSION
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        print('[AuthBloc] Signing in user: ${event.email}');
        final response = await _authRepository.signIn(email: event.email, password: event.password);
        if (response.user != null) {
          try {
            final profile = await _profileRepository.getProfile(response.user!.id);
            bool isNew = profile.dailyCalorieTarget == 0 || profile.primaryGoal == null || profile.primaryGoal!.isEmpty;
            print('[AuthBloc] Login success. isNewUser: $isNew');
            emit(AuthAuthenticated(response.user!, isNewUser: isNew));
          } catch (e) {
            print('[AuthBloc] Login success but profile fetch failed: $e. Routing to Onboarding.');
            emit(AuthAuthenticated(response.user!, isNewUser: true));
          }
        }
      } catch (e) {
        print('[AuthBloc] Sign in error: $e');
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _authRepository.signUp(
          email: event.email, 
          password: event.password, 
          fullName: event.fullName
        );
        if (response.user != null) {
          // Alur: Registrasi sukses -> arahkan balik ke login dengan data terisi
          emit(AuthUnauthenticated(
            prefilledEmail: event.email,
            prefilledPassword: event.password,
          ));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthOnboardingCompleted>((event, emit) {
      if (state is AuthAuthenticated) {
        final curr = state as AuthAuthenticated;
        emit(AuthAuthenticated(curr.user, isNewUser: false));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    });
  }
}

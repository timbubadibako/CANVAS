import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/repositories/auth_repository.dart';

// --- Events ---
abstract class AuthEvent {}
class AuthCheckRequested extends AuthEvent {} // Event baru untuk cek session
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

// --- States ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    // Handler untuk cek session saat startup
    on<AuthCheckRequested>((event, emit) async {
      final user = _authRepository.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _authRepository.signIn(email: event.email, password: event.password);
        if (response.user != null) {
          emit(AuthAuthenticated(response.user!));
        } else {
          emit(AuthFailure("Invalid login response"));
        }
      } catch (e) {
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
          emit(AuthAuthenticated(response.user!));
        } else {
          emit(AuthFailure("Registration failed"));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    });
  }
}

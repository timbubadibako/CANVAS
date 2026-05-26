import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signIn({required String email, required String password});
  Future<AuthResponse> signUp({required String email, required String password, required String fullName});
  Future<void> signOut();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
}

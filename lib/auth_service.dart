import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signInWithPassword(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign-in failed');

    final role = await getUserRole(user.id);

    if (role != 'driver') {
      await signOut(); // Force sign-out
      throw Exception('Access denied: only drivers can sign in.');
    }

    // Continue if driver
  }


  Future<String?> getUserRole(String userId) async {
    final response = await _supabase
        .from('users')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    return response?['role'] as String?;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'notifiers.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  User? get currentUser => _supabase.auth.currentUser;

Future<void> signInWithPassword(String email, String password) async {
  final response = await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );

  final user = response.user;
  final session = response.session;

  if (user == null || session == null) {
    throw Exception('Invalid credentials.');
  }

  // Check role before letting GoRouter react
  final role = await getUserRole(user.id);

if (role != 'driver') {
  await signOut();
  throw Exception('Access denied: only drivers can log in.');
}

authNotifier.value = !authNotifier.value;


  // Role is valid, do nothing – GoRouter will now redirect
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
  authNotifier.value = !authNotifier.value; // ✅ Force GoRouter to refresh
}

}

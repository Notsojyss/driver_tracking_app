import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://rhyjfxcldncomaxrzajq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJoeWpmeGNsZG5jb21heHJ6YWpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3NDg3NjIsImV4cCI6MjA2NTMyNDc2Mn0.pPq8rAXNz_IGaAHfdcBoh6K82YaT7Xj6A_ix_34HpNc',
  );

  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      redirect: (context, state) {
        final authService = AuthService();
        if (authService.currentUser == null) {
          return '/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
  refreshListenable:
      GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Driver Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

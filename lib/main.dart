import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/splash_page.dart';
import 'screens/profile_page.dart';

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
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
  refreshListenable:
      GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  redirect: (BuildContext context, GoRouterState state) {
    final authService = AuthService();
    final loggedIn = authService.currentUser != null;
    final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    // If the user is not logged in and not trying to log in, redirect to the login page.
    if (!loggedIn && !loggingIn) {
      return '/login';
    }

    // If the user is logged in and trying to access a login page, redirect to the home page.
    if (loggedIn && loggingIn) {
      return '/';
    }

    // No redirect needed.
    return null;
  },
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
        _authSubscription.cancel();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        home: SplashPage(),
      );
    }
    return MaterialApp.router(
      title: 'Driver Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

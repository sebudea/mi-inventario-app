import 'package:go_router/go_router.dart';
import '../ui/views/login/login_screen.dart';
import '../ui/views/home/home_screen.dart';
import '../services/auth_service.dart';

GoRouter appRouter(AuthService authService) {
  return GoRouter(
    // Al iniciar, muestra la pantalla de login
    initialLocation: '/login',

    routes: [
      // Pantalla de login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authService.isLoggedIn;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
      return null;
    },
    refreshListenable: authService,
  );
}

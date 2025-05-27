import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../ui/views/login/login_screen.dart';
import '../ui/views/home/home_screen.dart';

GoRouter appRouter(AuthService authService) {
  return GoRouter(
    // Al iniciar, muestra la pantalla de login
    initialLocation: '/login',

    // Escucha cambios en el estado de autenticación
    refreshListenable: authService,

    redirect: (context, state) {
      // ¿El usuario está logueado?
      final loggedIn = authService.isLoggedIn;

      // ¿Está en la pantalla de login?
      final loggingIn = state.matchedLocation == '/login';

      // Si NO está logueado y NO está en login, redirige a login
      if (!loggedIn && !loggingIn) return '/login';

      // Si está logueado y está en login, redirige a home
      if (loggedIn && loggingIn) return '/home';

      // Si ninguna condición se cumple, no redirige
      return null;
    },
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
  );
}

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_inventario/features/auth/presentation/providers/auth_provider.dart';
import 'package:mi_inventario/features/auth/presentation/screens/login_screen.dart';
import 'package:mi_inventario/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:mi_inventario/features/inventory/presentation/screens/inventory_detail_screen.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const InventoryListScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/inventory/:id',
        builder: (context, state) {
          final inventory = state.extra as Inventory;
          return InventoryDetailScreen(inventory: inventory);
        },
      ),
    ],
  );
}

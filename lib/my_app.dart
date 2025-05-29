import 'package:flutter/material.dart';
import 'package:mi_inventario/data/services/inventory_firestore_service.dart';
import 'package:mi_inventario/ui/viewmodels/inventory_viewmodel.dart';
import 'package:mi_inventario/ui/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

import 'data/repositories/inventory_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/user_firestore_service.dart';
import 'routing/router.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userFirestoreService = UserFirestoreService();
    final userRepository = UserRepository(userFirestoreService);

    final inventoryFirestoreService = InventoryFirestoreService();
    final inventoryRepository = InventoryRepository(inventoryFirestoreService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepository)),
        ChangeNotifierProvider(
            create: (_) => InventoryViewModel(inventoryRepository)),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp.router(
            routerConfig: appRouter(authService),
            title: 'Mi Inventario',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
              ),
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }
}

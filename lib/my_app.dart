import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routing/router.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
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

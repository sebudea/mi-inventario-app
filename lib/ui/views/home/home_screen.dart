import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              authService.logout();
              // go_router se encargará del redirect
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido! Has iniciado sesión.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

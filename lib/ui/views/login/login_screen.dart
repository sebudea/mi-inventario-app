import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(220, 48),
            side: const BorderSide(color: Colors.grey),
            elevation: 2,
          ),
          icon: Image.network(
            'https://developers.google.com/identity/images/g-logo.png',
            height: 24,
            width: 24,
          ),
          label: const Text('Iniciar sesión con Google'),
          onPressed: () async {
            await authService.login(username: 'google_user', password: '');
            // go_router se encargará del redirect
          },
        ),
      ),
    );
  }
}

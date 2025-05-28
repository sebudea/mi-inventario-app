import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mi_inventario/ui/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../domain/user/user_model.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2,
                size: 72,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido a Mi Inventario',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestiona tus articulos de forma sencilla y segura.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(220, 48),
                    side: const BorderSide(color: Colors.grey),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: authService.loading
                      ? const SizedBox.shrink()
                      : Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                          height: 34,
                          width: 34,
                        ),
                  label: authService.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión con Google'),
                  onPressed: authService.loading
                      ? null
                      : () async {
                          User? user = await authService.signInWithGoogle();
                          if (user != null) {
                            UserModel userData = UserModel(
                              id: user.uid,
                              name: user.displayName ?? 'Usuario',
                              email: user.email ?? 'Sin correo',
                            );
                            await userViewModel.loadUser(userData);
                          } else {
                            debugPrint('Usuario no autenticado a tiempo');
                          }
                        },
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '© 2025 Mi Inventario',
                style: TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

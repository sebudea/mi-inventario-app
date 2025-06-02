import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_inventario/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.watch(authProvider.notifier);
    final isLoading = ref.watch(authProvider.notifier).isLoading;

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
                  icon: isLoading
                      ? const SizedBox.shrink()
                      : Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                          height: 34,
                          width: 34,
                        ),
                  label: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión con Google'),
                  onPressed: isLoading
                      ? null
                      : () async {
                          await authNotifier.signInWithGoogle();
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

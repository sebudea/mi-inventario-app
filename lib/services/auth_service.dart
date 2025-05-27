import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(
      {required String username, required String password}) async {
    // Simula un retardo de red
    await Future.delayed(const Duration(seconds: 1));
    // Aquí podrías agregar lógica real de autenticación
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  User? _firebaseUser;
  bool _loading = false;

  User? get firebaseUser => _firebaseUser;
  bool get isLoggedIn => _firebaseUser != null;
  bool get loading => _loading;

  Future<User?> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();

      // Inicia el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return null;
      }

      // Obtiene los detalles de autenticación de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Crea una nueva credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase con la credencial de Google
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      _firebaseUser = userCredential.user;
      _loading = false;
      notifyListeners();
      return _firebaseUser;
    } catch (e) {
      _loading = false;
      notifyListeners();
      // Puedes manejar el error aquí o mostrar un mensaje
      debugPrint('Error en signInWithGoogle: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    _firebaseUser = null;
    notifyListeners();
    debugPrint('Usuario desconectado');
  }
}

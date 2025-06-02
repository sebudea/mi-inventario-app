import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mi_inventario/features/auth/domain/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  UserModel? build() {
    debugPrint('🔐 Inicializando Auth Provider');
    _setupAuthStateListener();
    return null;
  }

  void _setupAuthStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      debugPrint('👤 Cambio en el estado de autenticación');
      if (firebaseUser != null) {
        debugPrint('✅ Usuario autenticado: ${firebaseUser.email}');
        state = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
        );
      } else {
        debugPrint('❌ Usuario no autenticado');
        state = null;
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔄 Iniciando proceso de login con Google');
      _isLoading = true;
      state = null;

      final GoogleSignIn googleSignIn = GoogleSignIn();
      debugPrint('📱 Solicitando cuenta de Google');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Usuario canceló el login de Google');
        _isLoading = false;
        return;
      }

      debugPrint('🔑 Obteniendo credenciales de Google');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔒 Autenticando con Firebase');
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('✅ Login exitoso: ${userCredential.user?.email}');
    } catch (e) {
      debugPrint('🚫 Error en login: $e');
      state = null;
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔄 Iniciando proceso de logout');
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Logout exitoso');
      state = null;
    } catch (e) {
      debugPrint('🚫 Error en logout: $e');
      throw Exception('Error al cerrar sesión');
    }
  }
}

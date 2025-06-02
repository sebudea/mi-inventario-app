import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mi_inventario/features/auth/domain/user.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  User? build() {
    _setupAuthStateListener();
    return null;
  }

  void _setupAuthStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        state = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
        );
      } else {
        state = null;
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      state = null;
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Start the interactive sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        return;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      state = null;
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      state = null;
    } catch (e) {
      throw Exception('Error al cerrar sesión');
    }
  }
}

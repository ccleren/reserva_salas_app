import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Emite el User? actual; si es null, está deslogueado.
  Stream<User?> get userChanges => _auth.authStateChanges();

  // ───── Email/Password ─────
  Future<UserCredential> signIn(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email, password: pass);

  Future<UserCredential> register(String email, String pass) =>
      _auth.createUserWithEmailAndPassword(email: email, password: pass);

  // ───── Google ─────
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Login cancelado');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // ───── Facebook ─────
  Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook login cancelado');
    }
    final credential =
        FacebookAuthProvider.credential(result.accessToken!.token);
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();
}

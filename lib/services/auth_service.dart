// auth_service.dart
// Layanan autentikasi: register, login email/password, login Google, logout.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Google Sign-In cukup di-initialize() satu kali, jadi dipakai penanda static.
  static bool _googleReady = false;

  // Daftar akun baru dengan email & password.
  Future<void> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  // Login dengan email & password.
  Future<void> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  // Login dengan akun Google (google_sign_in versi 7.x).
  Future<void> signInWithGoogle() async {
    final google = GoogleSignIn.instance;

    if (!_googleReady) {
      // Ganti WEB_CLIENT_ID dengan Web client ID dari Firebase Console
      // (Authentication -> Sign-in method -> Google).
      await google.initialize(serverClientId: '1075478631779-9338s4d94cbm69tt4ktrlmfd96rd27fu.apps.googleusercontent.com');
      _googleReady = true;
    }

    // Menampilkan dialog pemilihan akun Google.
    final account = await google.authenticate();

    // Token Google ditukar menjadi credential Firebase.
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await _auth.signInWithCredential(credential);
  }

  // Keluar dari akun.
  Future<void> logout() => _auth.signOut();
}

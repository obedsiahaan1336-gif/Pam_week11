// login_screen.dart
// Halaman login: email/password, registrasi, dan login Google.
// Setelah berhasil, StreamBuilder di main.dart otomatis pindah ke HomeShell.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false; // true saat proses login berjalan

  @override
  void dispose() {
    // Bebaskan controller agar tidak terjadi memory leak.
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Menampilkan pesan singkat (SnackBar).
  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Pembungkus semua aksi auth: atur loading + tangani error dengan ramah.
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? e.code);
    } on GoogleSignInException {
      _show('Login Google dibatalkan atau gagal');
    } catch (e) {
      _show('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('PAM Notes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true, // sembunyikan password
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                // Tombol dinonaktifkan (null) saat loading.
                FilledButton(
                  onPressed: _loading
                      ? null
                      : () => _run(
                          () => _auth.login(_email.text.trim(), _password.text)),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () => _run(() =>
                          _auth.register(_email.text.trim(), _password.text)),
                  child: const Text('Register'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed:
                      _loading ? null : () => _run(_auth.signInWithGoogle),
                  icon: const Icon(Icons.login),
                  label: const Text('Masuk dengan Google'),
                ),
                if (_loading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

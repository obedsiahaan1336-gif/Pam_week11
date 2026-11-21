// main.dart
// Titik masuk aplikasi PAM Notes.
// Tugasnya: inisialisasi Firebase & AdMob, lalu memilih halaman
// berdasarkan status login (sudah login -> HomeShell, belum -> LoginScreen).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart'; // dibuat otomatis oleh `flutterfire configure`
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin (Firebase, AdMob) di main().
  WidgetsFlutterBinding.ensureInitialized();

  // Menghubungkan aplikasi ke proyek Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Menyiapkan SDK iklan Google (AdMob).
  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAM Notes',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // StreamBuilder memantau status login secara real-time.
      // Saat login/logout, halaman otomatis berganti tanpa Navigator.push.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          // Sedang memeriksa status login -> tampilkan loading.
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // snap.hasData = ada user yang login.
          return snap.hasData ? const HomeShell() : const LoginScreen();
        },
      ),
    );
  }
}

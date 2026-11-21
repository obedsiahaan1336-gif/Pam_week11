// notes_screen.dart
// Halaman catatan: daftar real-time dari Firestore.
// Tombol + untuk tambah, ketuk catatan untuk ubah, ikon sampah untuk hapus.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notes_repository.dart';

class NotesScreen extends StatelessWidget {
  NotesScreen({super.key});

  final _repo = NotesRepository();

  // Dialog input judul. Mengembalikan teks, atau null jika dibatalkan.
  Future<String?> _askTitle(BuildContext context, {String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(initial.isEmpty ? 'Catatan baru' : 'Ubah catatan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tulis catatan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          // Tombol logout di pojok kanan atas.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repo.watch(),
        builder: (context, snap) {
          // 1) Gagal (mis. ditolak Security Rules).
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          // 2) Masih memuat.
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // 3) Data kosong.
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada catatan'));
          }
          // 4) Tampilkan daftar.
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              return ListTile(
                title: Text(d['title'] as String),
                // Ketuk = ubah catatan.
                onTap: () async {
                  final title =
                      await _askTitle(context, initial: d['title'] as String);
                  if (title != null && title.isNotEmpty) {
                    await _repo.update(d.id, title);
                  }
                },
                // Ikon sampah = hapus catatan.
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _repo.delete(d.id),
                ),
              );
            },
          );
        },
      ),
      // Tombol tambah catatan.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await _askTitle(context);
          if (title != null && title.isNotEmpty) {
            await _repo.add(title);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

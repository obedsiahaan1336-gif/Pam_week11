// notes_repository.dart
// Repository untuk CRUD catatan di Cloud Firestore (koleksi 'notes').
// Field dokumen: title (string), uid (string), createdAt (timestamp).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesRepository {
  final _db = FirebaseFirestore.instance;

  // UID pengguna yang sedang login.
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // CREATE: tambah catatan baru milik pengguna.
  Future<void> add(String title) => _db.collection('notes').add({
        'title': title,
        'uid': _uid,
        'createdAt': FieldValue.serverTimestamp(), // waktu dari server
      });

  // READ (real-time): hanya catatan milik pengguna yang login.
  // where('uid') WAJIB ada agar query sesuai dengan Security Rules.
  Stream<QuerySnapshot<Map<String, dynamic>>> watch() => _db
      .collection('notes')
      .where('uid', isEqualTo: _uid)
      .snapshots();

  // UPDATE: ubah judul catatan berdasarkan id dokumen.
  Future<void> update(String id, String title) =>
      _db.collection('notes').doc(id).update({'title': title});

  // DELETE: hapus catatan berdasarkan id dokumen.
  Future<void> delete(String id) => _db.collection('notes').doc(id).delete();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whacka_app/models/note.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? 'guest-user';

  Future<void> saveNote(Note note) async {
    final doc = _firestore.collection('notes').doc();
    final data = note.toMap();
    data['created_at'] = Timestamp.fromDate(note.createdAt);
    await doc.set({
      ...data,
      'userId': currentUserId,
      'id': doc.id,
    });
  }

  Future<List<Note>> getNotes() async {
    final snapshot = await _firestore
        .collection('notes')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Note.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final snapshot = await _firestore
        .collection('notes')
        .where('userId', isEqualTo: currentUserId)
        .get();

    final all = snapshot.docs
        .map((doc) => Note.fromMap(doc.data(), doc.id))
        .toList();

    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return all;

    return all.where((note) {
      return note.title.toLowerCase().contains(normalized) ||
          note.content.toLowerCase().contains(normalized);
    }).toList();
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  Future<void> toggleFavorite(String noteId, bool currentValue) async {
    await _firestore.collection('notes').doc(noteId).update({
      'is_favorite': !currentValue,
    });
  }
}

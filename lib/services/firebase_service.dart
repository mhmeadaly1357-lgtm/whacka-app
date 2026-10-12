import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whacka_app/models/note.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? 'guest-user';
  String get currentUserEmail => _auth.currentUser?.email ?? 'guest@example.com';

  /// ✅ حفظ مذكرة جديدة
  Future<void> saveNote(Note note) async {
    try {
      final doc = _firestore.collection('notes').doc();
      final data = note.toMap();
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await doc.set({
        ...data,
        'userId': currentUserId,
        'id': doc.id,
      });
      
      print('✅ تم حفظ المذكرة: ${doc.id}');
    } catch (e) {
      print('❌ خطأ في حفظ المذكرة: $e');
      rethrow;
    }
  }

  /// ✅ جلب جميع المذكرات
  Future<List<Note>> getNotes() async {
    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب المذكرات: $e');
      return [];
    }
  }

  /// ✅ البحث في المذكرات
  Future<List<Note>> searchNotes(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getNotes();
      }

      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final allNotes = snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList();

      final normalized = query.trim().toLowerCase();
      return allNotes.where((note) {
        return note.title.toLowerCase().contains(normalized) ||
            note.content.toLowerCase().contains(normalized);
      }).toList();
    } catch (e) {
      print('❌ خطأ في البحث: $e');
      return [];
    }
  }

  /// ✅ حذف مذكرة
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      print('✅ تم حذف المذكرة: $noteId');
    } catch (e) {
      print('❌ خطأ في حذف المذكرة: $e');
      rethrow;
    }
  }

  /// ✅ تحديث مذكرة
  Future<void> updateNote(String noteId, Note note) async {
    try {
      final data = note.toMap();
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('notes').doc(noteId).update(data);
      print('✅ تم تحديث المذكرة: $noteId');
    } catch (e) {
      print('❌ خطأ في تحديث المذكرة: $e');
      rethrow;
    }
  }

  /// ✅ إضافة/إزالة من المفضلة
  Future<void> toggleFavorite(String noteId, bool currentValue) async {
    try {
      await _firestore.collection('notes').doc(noteId).update({
        'is_favorite': !currentValue,
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ تم تحديث المفضلة: $noteId');
    } catch (e) {
      print('❌ خطأ: $e');
      rethrow;
    }
  }

  /// ✅ حفظ محادثة عاطفية
  Future<String> saveConversation(String emotion) async {
    try {
      final doc = _firestore.collection('conversations').doc();
      await doc.set({
        'userId': currentUserId,
        'emotion': emotion,
        'created_at': FieldValue.serverTimestamp(),
      });
      print('✅ تم إنشاء محادثة: ${doc.id}');
      return doc.id;
    } catch (e) {
      print('❌ خطأ في إنشاء المحادثة: $e');
      rethrow;
    }
  }

  /// ✅ إضافة رسالة إلى محادثة
  Future<void> addMessageToConversation({
    required String conversationId,
    required String role,
    required String content,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'role': role,
        'content': content,
        'created_at': FieldValue.serverTimestamp(),
      });
      print('✅ تم إضافة رسالة إلى المحادثة');
    } catch (e) {
      print('❌ خطأ في إضافة الرسالة: $e');
      rethrow;
    }
  }

  /// ✅ جلب رسائل المحادثة
  Future<List<Map<String, dynamic>>> getConversationMessages(
    String conversationId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('created_at', descending: false)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ خطأ في جلب الرسائل: $e');
      return [];
    }
  }

  /// ✅ تسجيل دخول بدون كلمة مرور (Anonymous)
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      print('✅ تم تسجيل الدخول بدون كلمة مرور');
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      rethrow;
    }
  }

  /// ✅ تسجيل خروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ تم تسجيل الخروج');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
      rethrow;
    }
  }

  /// ✅ التحقق من تسجيل الدخول
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}

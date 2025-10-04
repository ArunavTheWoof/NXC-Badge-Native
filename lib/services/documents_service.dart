import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';
import 'package:test_app1/services/supabase_sync_service.dart';

/// Documents service aligned to the single `/documents/{docId}` schema where
/// each document belongs to a specific user.
class DocumentsService {
  static const String documentsCollection = 'documents';
  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Upload or register a document for a user. Returns the generated docId.
  static Future<String> uploadDocumentForUser({
    required String userId,
    required String type,
    required String fileUrl,
    DateTime? uploadedAt,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await SupabaseSyncService.upsertDocument(
        DocumentSyncRecord(
          userId: userId,
          type: type,
          fileUrl: fileUrl,
          uploadedAt: uploadedAt ?? DateTime.now().toUtc(),
          extra: {
            'hidden': extra?['hidden'] ?? false,
            if (extra != null) ...extra,
          },
        ),
      );
    } catch (e) {
      LogService.error('Error uploading document for $userId', error: e);
      rethrow;
    }
  }

  /// Convenience alias for backwards compatibility with "issue" terminology.
  static Future<String> issueDocument({
    required String userId,
    required String type,
    required String fileUrl,
    String? issuedBy,
    bool hidden = false,
  }) {
    return uploadDocumentForUser(
      userId: userId,
      type: type,
      fileUrl: fileUrl,
      extra: {
        'issuedBy': issuedBy,
        'hidden': hidden,
      },
    );
  }

  /// Fetch documents for a user.
  static Future<List<Map<String, dynamic>>> fetchIssuedForUser(
    String userId, {
    bool includeHidden = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection(documentsCollection)
          .where('userId', isEqualTo: userId);
      if (!includeHidden) {
        query = query.where('hidden', isEqualTo: false);
      }
      final snap = await query.orderBy('uploadedAt', descending: true).limit(100).get();
      return snap.docs.map(_mapDoc).toList();
    } catch (e) {
      LogService.error('Error fetching documents for $userId', error: e);
      return [];
    }
  }

  static Map<String, dynamic> _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return {
      ...data,
      'docId': doc.id,
    };
  }

  /// Hide a document (soft delete).
  static Future<void> hideIssuedDoc(String docId) async {
    try {
      await _db.collection(documentsCollection).doc(docId).set({
        'hidden': true,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      LogService.error('Error hiding document $docId', error: e);
      rethrow;
    }
  }

  /// Unhide a document.
  static Future<void> unhideIssuedDoc(String docId) async {
    try {
      await _db.collection(documentsCollection).doc(docId).set({
        'hidden': false,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      LogService.error('Error unhiding document $docId', error: e);
      rethrow;
    }
  }

  /// Fetch a single document.
  static Future<Map<String, dynamic>?> getDocument(String docId) async {
    try {
      final doc = await _db.collection(documentsCollection).doc(docId).get();
      if (!doc.exists) return null;
      return {
        ...?doc.data(),
        'docId': doc.id,
      };
    } catch (e) {
      LogService.error('Error fetching document $docId', error: e);
      return null;
    }
  }

  /// Permanently delete a document.
  static Future<void> deleteDocument(String docId) async {
    try {
      await _db.collection(documentsCollection).doc(docId).delete();
    } catch (e) {
      LogService.error('Error deleting document $docId', error: e);
      rethrow;
    }
  }
}

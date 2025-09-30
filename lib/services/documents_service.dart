import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Documents & issuance domain service.
/// Collections:
/// /documents/{docId}
///   - docId
///   - type (hallticket, eventPass, etc.)
///   - meta (Map<String,dynamic>)
///   - createdBy (adminId)
///   - createdAt / updatedAt
/// /issuedDocs/{id}
///   - id
///   - docId
///   - userId
///   - hidden (bool)
///   - issuedBy (adminId)
///   - issuedAt
///   - updatedAt
class DocumentsService {
  static const String documentsCollection = 'documents';
  static const String issuedCollection = 'issuedDocs';
  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Create a new document definition (admin only expected path)
  static Future<String> createDocument({
    required String type,
    required Map<String, dynamic> meta,
    required String createdBy,
  }) async {
    try {
      final ref = _db.collection(documentsCollection).doc();
      await ref.set({
        'docId': ref.id,
        'type': type,
        'meta': meta,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      LogService.error('Error creating document', error: e);
      rethrow;
    }
  }

  /// Issue an existing document to a user
  static Future<String> issueDocument({
    required String docId,
    required String userId,
    required String issuedBy,
    bool hidden = false,
  }) async {
    try {
      final ref = _db.collection(issuedCollection).doc();
      await ref.set({
        'id': ref.id,
        'docId': docId,
        'userId': userId,
        'hidden': hidden,
        'issuedBy': issuedBy,
        'issuedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      LogService.error('Error issuing document', error: e);
      rethrow;
    }
  }

  /// Fetch issued (visible) documents for a user.
  static Future<List<Map<String, dynamic>>> fetchIssuedForUser(String userId, {bool includeHidden = false}) async {
    try {
      Query query = _db.collection(issuedCollection).where('userId', isEqualTo: userId);
      if (!includeHidden) {
        query = query.where('hidden', isEqualTo: false);
      }
      final snap = await query.orderBy('issuedAt', descending: true).limit(100).get();
      return snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
    } catch (e) {
      LogService.error('Error fetching issued documents', error: e);
      return [];
    }
  }

  /// Hide an issued document (soft remove from user view)
  static Future<void> hideIssuedDoc(String id) async {
    try {
      await _db.collection(issuedCollection).doc(id).update({
        'hidden': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LogService.error('Error hiding issued doc', error: e);
      rethrow;
    }
  }

  /// Unhide an issued document
  static Future<void> unhideIssuedDoc(String id) async {
    try {
      await _db.collection(issuedCollection).doc(id).update({
        'hidden': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LogService.error('Error unhiding issued doc', error: e);
      rethrow;
    }
  }

  /// Optional: get base document definition for enrichment
  static Future<Map<String, dynamic>?> getDocument(String docId) async {
    try {
      final doc = await _db.collection(documentsCollection).doc(docId).get();
      return doc.data();
    } catch (e) {
      LogService.error('Error fetching document', error: e);
      return null;
    }
  }
}

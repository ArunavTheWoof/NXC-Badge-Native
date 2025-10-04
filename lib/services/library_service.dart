import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';
import 'package:test_app1/services/supabase_sync_service.dart';

/// Service layer for librarian-related book issue workflows.
/// Collection structure:
/// /library/{transactionId}
///   - transactionId
///   - userId
///   - bookId
///   - bookTitle
///   - issuedAt (ISO string)
///   - returnedAt (ISO string or null)
///   - [status, dueDate, librarianId, etc.]
class LibraryService {
  static const String issuesCollection = 'library';
  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Create a new issue record. Returns issueId.
  static Future<String> createIssue({
    required String userId,
    required String bookId,
    required String bookTitle,
    required DateTime issueDate,
    required DateTime dueDate,
    String? librarianId,
  }) async {
    try {
      final recordId = await SupabaseSyncService.recordLibraryTransaction(
        LibrarySyncRecord(
          userId: userId,
          bookId: bookId,
          bookTitle: bookTitle,
          issuedAt: issueDate.toUtc(),
          extra: {
            'status': 'issued',
            'dueDate': dueDate.toUtc().toIso8601String(),
            'createdAt': issueDate.toUtc().toIso8601String(),
            if (librarianId != null) 'librarianId': librarianId,
          },
        ),
      );
      return recordId;
    } catch (e) {
      LogService.error('Error creating library issue', error: e);
      rethrow;
    }
  }

  /// Mark an issue as returned (idempotent).
  static Future<void> markReturned(String issueId, {DateTime? returnDate}) async {
    try {
      final returnedAt = (returnDate ?? DateTime.now()).toUtc();
      await _db.collection(issuesCollection).doc(issueId).set({
        'returnedAt': returnedAt.toIso8601String(),
        'status': 'returned',
        'updatedAt': returnedAt.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      LogService.error('Error marking issue returned', error: e);
      rethrow;
    }
  }

  /// Fetch active issues for a user.
  static Future<List<Map<String, dynamic>>> fetchActiveIssuesForUser(String userId) async {
    try {
      final snap = await _db
          .collection(issuesCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'issued')
          .orderBy('issuedAt', descending: true)
          .get();
      return snap.docs.map(_mapIssueDoc).toList();
    } catch (e) {
      LogService.error('Error fetching active issues', error: e);
      return [];
    }
  }

  /// Fetch issue history for a user (including returned).
  static Future<List<Map<String, dynamic>>> fetchIssueHistory(String userId) async {
    try {
      final snap = await _db
          .collection(issuesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('issuedAt', descending: true)
          .limit(200)
          .get();
      return snap.docs.map(_mapIssueDoc).toList();
    } catch (e) {
      LogService.error('Error fetching issue history', error: e);
      return [];
    }
  }

  /// Stream active issues for real-time UI.
  static Stream<List<Map<String, dynamic>>> activeIssuesStream(String userId) {
    return _db
        .collection(issuesCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'issued')
        .orderBy('issuedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_mapIssueDoc).toList());
  }

  static Map<String, dynamic> _mapIssueDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return {
      ...data,
      'issueId': doc.id,
    };
  }
}

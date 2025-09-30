import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Service layer for librarian-related book issue workflows.
/// Collection structure:
/// /libraryIssues/{issueId}
///   - issueId
///   - userId
///   - bookTitle
///   - issueDate (Timestamp)
///   - dueDate (Timestamp)
///   - returnDate (Timestamp?)
///   - status ("issued" | "returned")
///   - createdAt / updatedAt
class LibraryService {
  static const String issuesCollection = 'libraryIssues';
  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Create a new issue record. Returns issueId.
  static Future<String> createIssue({
    required String userId,
    required String bookTitle,
    required DateTime issueDate,
    required DateTime dueDate,
  }) async {
    try {
      final ref = _db.collection(issuesCollection).doc();
      await ref.set({
        'issueId': ref.id,
        'userId': userId,
        'bookTitle': bookTitle,
        'issueDate': Timestamp.fromDate(issueDate.toUtc()),
        'dueDate': Timestamp.fromDate(dueDate.toUtc()),
        'status': 'issued',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      LogService.error('Error creating library issue', error: e);
      rethrow;
    }
  }

  /// Mark an issue as returned (idempotent).
  static Future<void> markReturned(String issueId, {DateTime? returnDate}) async {
    try {
      final ref = _db.collection(issuesCollection).doc(issueId);
      await ref.update({
        'status': 'returned',
        'returnDate': Timestamp.fromDate((returnDate ?? DateTime.now()).toUtc()),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
          .orderBy('issueDate', descending: true)
          .get();
      return snap.docs.map((d) => d.data()).toList();
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
          .orderBy('issueDate', descending: true)
          .limit(200)
          .get();
      return snap.docs.map((d) => d.data()).toList();
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
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}

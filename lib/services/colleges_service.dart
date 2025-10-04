import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';
import 'package:test_app1/services/supabase_sync_service.dart';

/// Service for working with the `/colleges/{collegeId}` collection.
class CollegesService {
  static const String collectionPath = 'colleges';
  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Create or update a college record using the enforced schema.
  static Future<void> upsertCollege({
    required String collegeId,
    required String name,
    required int eventLimit,
    required int monthlyEventCount,
    required DateTime resetDate,
    Map<String, dynamic>? extra,
  }) async {
    try {
      await SupabaseSyncService.upsertCollege(
        CollegeSyncRecord(
          collegeId: collegeId,
          name: name,
          eventLimit: eventLimit,
          monthlyEventCount: monthlyEventCount,
          resetDate: resetDate,
          extra: extra,
        ),
      );
    } catch (e) {
      LogService.error('Error upserting college $collegeId', error: e);
      rethrow;
    }
  }

  /// Fetch a single college record.
  static Future<Map<String, dynamic>?> getCollege(String collegeId) async {
    try {
      final doc = await _db.collection(collectionPath).doc(collegeId).get();
      if (!doc.exists) return null;
      return {
        ...?doc.data(),
        'collegeId': doc.id,
      };
    } catch (e) {
      LogService.error('Error fetching college $collegeId', error: e);
      return null;
    }
  }

  /// Increment the monthly event count by 1 (bounded by [eventLimit]).
  static Future<void> incrementMonthlyEventCount(String collegeId) async {
    try {
      await _db.collection(collectionPath).doc(collegeId).update({
        'monthlyEventCount': FieldValue.increment(1),
      });
    } catch (e) {
      LogService.error('Error incrementing monthly event count for $collegeId', error: e);
      rethrow;
    }
  }

  /// Reset the monthly event count and update the reset date.
  static Future<void> resetMonthlyEventCount(String collegeId, DateTime resetDate) async {
    try {
      await _db.collection(collectionPath).doc(collegeId).set({
        'monthlyEventCount': 0,
        'resetDate': resetDate.toUtc().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      LogService.error('Error resetting monthly event count for $collegeId', error: e);
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

class AttendanceService {
  static const String recordsCollection = 'attendanceRecords';
  static const String aggCollection = 'attendanceAgg';
  static const String sessionsCollection = 'attendanceSessions';
  // Mirror collection (per-user doc) for simplified client reads if needed
  static const String mirrorCollection = 'attendance';

  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Initialize user aggregate doc if it doesn't exist
  static Future<void> ensureUserAggregate(String userId) async {
    final docRef = _db.collection(aggCollection).doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'userId': userId,
        'classes': {}, // classId -> {presentCount, totalCount}
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Record an attendance event
  static Future<void> recordAttendance({
    required String sessionId,
    required String userId,
    required String source,
    required String classId,
    bool present = true,
  }) async {
    try {
      final batch = _db.batch();
      final recordRef = _db.collection(recordsCollection).doc();
      batch.set(recordRef, {
        'recordId': recordRef.id,
        'sessionId': sessionId,
        'userId': userId,
        'source': source,
        'classId': classId,
        'present': present,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final aggRef = _db.collection(aggCollection).doc(userId);
      batch.set(aggRef, {
        'updatedAt': FieldValue.serverTimestamp(),
        'classes.$classId.presentCount': FieldValue.increment(present ? 1 : 0),
        'classes.$classId.totalCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      LogService.error('Error recording attendance', error: e);
      rethrow;
    }
  }

  /// Create an attendance session (e.g., class period) and return its ID
  static Future<String> createSession({
    required String startedBy,
    required String classOrEventId,
    DateTime? date,
  }) async {
    try {
      final ref = _db.collection(sessionsCollection).doc();
      await ref.set({
        'sessionId': ref.id,
        'classId': classOrEventId,
        'startedBy': startedBy,
        'date': (date ?? DateTime.now()).toUtc(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      LogService.error('Error creating session', error: e);
      rethrow;
    }
  }

  /// Fetch aggregate map for a user (returns empty if none)
  static Future<Map<String, dynamic>> fetchUserAggregate(String userId) async {
    try {
      final doc = await _db.collection(aggCollection).doc(userId).get();
      if (!doc.exists) return {};
      final data = doc.data() ?? {};
      return (data['classes'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      LogService.error('Error fetching user aggregate', error: e);
      return {};
    }
  }

  /// Mirror aggregate classes map into simplified /attendance/{userId} document
  static Future<void> mirrorUserAggregate(String userId, Map<String, dynamic> classes) async {
    try {
      await _db.collection(mirrorCollection).doc(userId).set({
        'userId': userId,
        'classes': classes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      LogService.error('Error mirroring attendance aggregate', error: e);
    }
  }

  /// Development/test utility: seed approximate 80% attendance across standard subjects.
  /// Will NOT overwrite subjects that already have >=10 totalCount.
  static Future<void> seedAttendanceForUser({
    required String userId,
    required String email,
    required Map<String, dynamic> existingClasses,
    List<_SeedSubject>? subjectsOverride,
  }) async {
    try {
      // Define default seed subjects
      final subjects = subjectsOverride ?? const [
        _SeedSubject('MATH101'),
        _SeedSubject('SCI101'),
        _SeedSubject('HIS101'),
        _SeedSubject('ENG101'),
        _SeedSubject('ART101'),
      ];

      await ensureUserAggregate(userId);

      for (final subj in subjects) {
        final stats = existingClasses[subj.classId] as Map<String, dynamic>?;
        final currentTotal = (stats?['totalCount'] as num?)?.toInt() ?? 0;
        if (currentTotal >= 10) continue; // Already seeded sufficiently

        // Target: 8 present out of 10
        const targetTotal = 10;
        const presentTarget = 8;
        final needed = targetTotal - currentTotal;
        if (needed <= 0) continue;

        for (int i = 0; i < needed; i++) {
          final sessionId = await createSession(
            startedBy: userId,
            classOrEventId: subj.classId,
          );
          final present = ( ( (stats?['presentCount'] as num?)?.toInt() ?? 0) + i ) < presentTarget;
            await recordAttendance(
              sessionId: sessionId,
              userId: userId,
              source: 'DEV_SEED',
              classId: subj.classId,
              present: present,
          );
        }
      }
    } catch (e) {
      LogService.error('Error seeding attendance data', error: e);
    }
  }

  /// Seed exact percentage targets (e.g., 69% and 70%) for given class IDs.
  /// If data already exceeds target totalCount, it will not downscale—only add needed sessions.
  /// percentage is integer 0-100, totalTarget is total sessions desired (default 100 for precision, can be smaller).
  static Future<void> seedExactPercentages({
    required String userId,
    required Map<String, int> classPercentTargets, // classId -> percent (e.g., 69)
    int totalTarget = 100,
  }) async {
    try {
      await ensureUserAggregate(userId);
      final current = await fetchUserAggregate(userId);

      for (final entry in classPercentTargets.entries) {
        final classId = entry.key;
        final percent = entry.value.clamp(0, 100);
        final stats = current[classId] as Map<String, dynamic>?;
        final presentCurrent = (stats?['presentCount'] as num?)?.toInt() ?? 0;
        final totalCurrent = (stats?['totalCount'] as num?)?.toInt() ?? 0;

        if (totalCurrent >= totalTarget) {
          // Already at or beyond target sampling window
          continue;
        }

        final desiredPresent = (percent * totalTarget / 100).round();
        final remainingTotal = totalTarget - totalCurrent;
        final remainingPresentNeeded = (desiredPresent - presentCurrent).clamp(0, remainingTotal);

        int presentAdded = 0;
        for (int i = 0; i < remainingTotal; i++) {
          final sessionId = await createSession(
            startedBy: userId,
            classOrEventId: classId,
          );
          final shouldBePresent = presentAdded < remainingPresentNeeded;
          await recordAttendance(
            sessionId: sessionId,
            userId: userId,
            source: 'DEV_SEED_EXACT',
            classId: classId,
            present: shouldBePresent,
          );
          if (shouldBePresent) presentAdded++;
        }
      }

      // Mirror after seeding
      final updated = await fetchUserAggregate(userId);
      await mirrorUserAggregate(userId, updated);
    } catch (e) {
      LogService.error('Error seeding exact attendance percentages', error: e);
    }
  }

  /// Quick demo seeding for any user: creates a small balanced dataset if empty.
  /// subjects: map of classId -> (present out of total). Defaults to 4/5 for each provided class.
  static Future<void> quickDemoSeed({
    required String userId,
    Map<String, Map<String, int>>? subjects,
  }) async {
    try {
      await ensureUserAggregate(userId);
      final existing = await fetchUserAggregate(userId);
      if (existing.isNotEmpty) return; // Don't overwrite
      final defs = subjects ?? {
        'MATH101': {'present': 4, 'total': 5},
        'SCI101': {'present': 4, 'total': 5},
        'HIS101': {'present': 3, 'total': 5},
        'ENG101': {'present': 5, 'total': 6},
      };
      for (final entry in defs.entries) {
        final classId = entry.key;
        final presentTarget = entry.value['present'] ?? 0;
        final totalTarget = entry.value['total'] ?? 0;
        for (int i = 0; i < totalTarget; i++) {
          final sessionId = await createSession(
            startedBy: userId,
            classOrEventId: classId,
          );
            await recordAttendance(
              sessionId: sessionId,
              userId: userId,
              source: 'DEV_QUICK_SEED',
              classId: classId,
              present: i < presentTarget,
            );
        }
      }
      final updated = await fetchUserAggregate(userId);
      await mirrorUserAggregate(userId, updated);
    } catch (e) {
      LogService.error('Error in quick demo seed', error: e);
    }
  }
}

class _SeedSubject {
  final String classId;
  const _SeedSubject(this.classId);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Service for managing academic classes and enrollment.
/// Collection: /classes/{classId}
/// Schema:
///   - classId
///   - name
///   - subjects: [String]
///   - studentCount
///   - studentIds: [String] (optional for quick membership lookup)
///   - teacherIds: [String]
///   - createdBy (adminId)
///   - createdAt / updatedAt
class ClassesService {
  static const String classesCollection = 'classes';
  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Create a new class definition.
  static Future<String> createClass({
    required String name,
    required List<String> subjects,
    required String createdByAdminId,
    List<String>? teacherIds,
  }) async {
    try {
      final ref = _db.collection(classesCollection).doc();
      await ref.set({
        'classId': ref.id,
        'name': name,
        'subjects': subjects,
        'studentCount': 0,
        'studentIds': <String>[],
        'teacherIds': teacherIds ?? <String>[],
        'createdBy': createdByAdminId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      LogService.error('Error creating class', error: e);
      rethrow;
    }
  }

  /// Fetch class doc
  static Future<Map<String, dynamic>?> getClass(String classId) async {
    try {
      final doc = await _db.collection(classesCollection).doc(classId).get();
      return doc.data();
    } catch (e) {
      LogService.error('Error fetching class', error: e);
      return null;
    }
  }

  /// Enroll a student: increments counters & updates user's classesEnrolled list.
  static Future<void> enrollStudent({
    required String classId,
    required String studentUserId,
  }) async {
    final classRef = _db.collection(classesCollection).doc(classId);
    final userRef = _db.collection('users').doc(studentUserId);

    await _db.runTransaction((txn) async {
      final classSnap = await txn.get(classRef);
      if (!classSnap.exists) {
        throw Exception('Class not found');
      }
      final classData = classSnap.data() ?? {};
      final currentStudentIds = List<String>.from(classData['studentIds'] ?? <String>[]);
      if (!currentStudentIds.contains(studentUserId)) {
        currentStudentIds.add(studentUserId);
      }

      txn.update(classRef, {
        'studentIds': currentStudentIds,
        'studentCount': currentStudentIds.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userSnap = await txn.get(userRef);
      if (!userSnap.exists) throw Exception('User not found');
      final userData = userSnap.data() ?? {};
      final classesEnrolled = List<String>.from(userData['classesEnrolled'] ?? <String>[]);
      if (!classesEnrolled.contains(classId)) {
        classesEnrolled.add(classId);
      }
      txn.update(userRef, {
        'classesEnrolled': classesEnrolled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Remove student from class (optional helper)
  static Future<void> unenrollStudent({
    required String classId,
    required String studentUserId,
  }) async {
    final classRef = _db.collection(classesCollection).doc(classId);
    final userRef = _db.collection('users').doc(studentUserId);
    await _db.runTransaction((txn) async {
      final classSnap = await txn.get(classRef);
      if (!classSnap.exists) return;
      final classData = classSnap.data() ?? {};
      final currentStudentIds = List<String>.from(classData['studentIds'] ?? <String>[]);
      currentStudentIds.remove(studentUserId);

      txn.update(classRef, {
        'studentIds': currentStudentIds,
        'studentCount': currentStudentIds.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userSnap = await txn.get(userRef);
      if (!userSnap.exists) return;
      final userData = userSnap.data() ?? {};
      final classesEnrolled = List<String>.from(userData['classesEnrolled'] ?? <String>[]);
      classesEnrolled.remove(classId);
      txn.update(userRef, {
        'classesEnrolled': classesEnrolled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Fetch all classes for given list of class IDs (batched)
  static Future<List<Map<String, dynamic>>> fetchClassesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      // Firestore IN queries limited to 30 ids; chunk if needed (simple version assumes < 30)
      final snap = await _db
          .collection(classesCollection)
          .where(FieldPath.documentId, whereIn: ids)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      LogService.error('Error fetching classes by IDs', error: e);
      return [];
    }
  }

  /// Fetch classes for a specific user (by reading user doc then classes)
  static Future<List<Map<String, dynamic>>> fetchClassesForUser(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];
      final data = userDoc.data() ?? {};
      final list = List<String>.from(data['classesEnrolled'] ?? <String>[]);
      return fetchClassesByIds(list);
    } catch (e) {
      LogService.error('Error fetching classes for user', error: e);
      return [];
    }
  }

  /// Add or remove teacher assignment
  static Future<void> updateTeacherAssignments({
    required String classId,
    required List<String> teacherIds,
  }) async {
    try {
      await _db.collection(classesCollection).doc(classId).update({
        'teacherIds': teacherIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LogService.error('Error updating teacher assignments', error: e);
      rethrow;
    }
  }
}

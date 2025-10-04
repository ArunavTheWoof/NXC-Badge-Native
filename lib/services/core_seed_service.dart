import 'package:test_app1/services/log_service.dart';
import 'package:test_app1/services/supabase_sync_service.dart';

/// Utility to seed the core Firestore collections so they appear in the console
/// with the expected schema. Intended for development/bootstrap usage only.
class CoreSeedService {
  CoreSeedService._();

  /// Seed demo documents across all required collections.
  static Future<void> seedDemoData() async {
    try {
      // 1. Users collection
      await SupabaseSyncService.upsertUser(
        UserSyncRecord(
          uid: 'john@example.com',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'student',
          collegeId: 'abc-college',
          dob: '2001-05-20',
          photoUrl: 'https://supabase.co/storage/v1/object/public/users/john.jpg',
          createdAt: DateTime.parse('2025-09-03T12:00:00Z'),
          extra: const {
            'status': 'demo-seed',
          },
        ),
      );

      // 2. Attendance collection
      await SupabaseSyncService.recordAttendance(
        AttendanceSyncRecord(
          attendanceId: 'attendance-demo-1',
          userId: 'john@example.com',
          collegeId: 'abc-college',
          status: AttendanceStatus.present,
          timestamp: DateTime.parse('2025-09-03T09:15:00Z'),
          extra: const {
            'source': 'demo-seed',
          },
        ),
      );

      // 3. Library collection
      await SupabaseSyncService.recordLibraryTransaction(
        LibrarySyncRecord(
          transactionId: 'lib-demo-1',
          userId: 'john@example.com',
          bookId: 'lib-12345',
          bookTitle: 'Data Structures in C',
          issuedAt: DateTime.parse('2025-09-03T10:00:00Z'),
          extra: const {
            'returnedAt': null,
            'status': 'issued',
          },
        ),
      );

      // 4. Documents collection
      await SupabaseSyncService.upsertDocument(
        DocumentSyncRecord(
          docId: 'doc-demo-1',
          userId: 'john@example.com',
          type: 'hallticket',
          fileUrl: 'https://supabase.co/storage/v1/object/public/documents/john-hallticket.pdf',
          uploadedAt: DateTime.parse('2025-09-03T11:30:00Z'),
        ),
      );

      // 5. Colleges collection
      await SupabaseSyncService.upsertCollege(
        CollegeSyncRecord(
          collegeId: 'abc-college',
          name: 'ABC College of Engineering',
          eventLimit: 10,
          monthlyEventCount: 7,
          resetDate: DateTime.parse('2025-09-01'),
        ),
      );

      LogService.info('Core demo data seeded successfully.');
    } catch (e) {
      LogService.error('Failed seeding core demo data', error: e);
      rethrow;
    }
  }
}

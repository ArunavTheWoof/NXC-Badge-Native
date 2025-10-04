import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Centralised helper for keeping Firestore in sync with updates that originate
/// from Supabase edge functions or other external backends.
///
/// Each helper below mirrors the exact collection schema that needs to exist in
/// Firestore so that the Supabase backend can simply hand us the payload and we
/// guarantee the document structure and collection creation. All writes use
/// `SetOptions(merge: true)` to keep the operations idempotent and safe to
/// retry.
class SupabaseSyncService {
  SupabaseSyncService._();

  static FirebaseFirestore get _db => FirebaseService.firestore;

  /// Upsert a `/users/{uid}` document using the required schema.
  static Future<void> upsertUser(UserSyncRecord record) async {
    try {
      final payload = record.toMap();
      payload['uid'] = record.uid;
      await _db.collection('users').doc(record.uid).set(
            payload,
            SetOptions(merge: true),
          );
    } catch (e, stack) {
      LogService.error('Failed to upsert user ${record.uid}', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Add (or overwrite) an entry in `/attendance/{attendanceId}`.
  static Future<String> recordAttendance(AttendanceSyncRecord record) async {
    try {
      final docRef = record.attendanceId != null && record.attendanceId!.isNotEmpty
          ? _db.collection('attendance').doc(record.attendanceId)
          : _db.collection('attendance').doc();

      final payload = record.toMap();
      payload['attendanceId'] = docRef.id;

      await docRef.set(payload, SetOptions(merge: true));
      return docRef.id;
    } catch (e, stack) {
      LogService.error('Failed to record attendance for ${record.userId}', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Record a library transaction under `/library/{transactionId}`.
  static Future<String> recordLibraryTransaction(LibrarySyncRecord record) async {
    try {
      final docRef = record.transactionId != null && record.transactionId!.isNotEmpty
          ? _db.collection('library').doc(record.transactionId)
          : _db.collection('library').doc();

      final payload = record.toMap();
      payload['transactionId'] = docRef.id;
      if (!payload.containsKey('returnedAt')) {
        payload['returnedAt'] = record.returnedAt != null ? _formatDateTime(record.returnedAt!) : null;
      }

      await docRef.set(payload, SetOptions(merge: true));
      return docRef.id;
    } catch (e, stack) {
      LogService.error('Failed to record library transaction for ${record.userId}', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Store a document reference under `/documents/{docId}`.
  static Future<String> upsertDocument(DocumentSyncRecord record) async {
    try {
      final docRef = record.docId != null && record.docId!.isNotEmpty
          ? _db.collection('documents').doc(record.docId)
          : _db.collection('documents').doc();

      final payload = record.toMap();
      payload['docId'] = docRef.id;

      await docRef.set(payload, SetOptions(merge: true));
      return docRef.id;
    } catch (e, stack) {
      LogService.error('Failed to upsert document for ${record.userId}', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Upsert a college record under `/colleges/{collegeId}`.
  static Future<void> upsertCollege(CollegeSyncRecord record) async {
    try {
  final payload = record.toMap();
  payload['collegeId'] = record.collegeId;

  await _db.collection('colleges').doc(record.collegeId).set(
    payload,
            SetOptions(merge: true),
          );
    } catch (e, stack) {
      LogService.error('Failed to upsert college ${record.collegeId}', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

/// Allowed attendance statuses.
enum AttendanceStatus { present, absent, late }

extension AttendanceStatusX on AttendanceStatus {
  String get value => switch (this) {
        AttendanceStatus.present => 'present',
        AttendanceStatus.absent => 'absent',
        AttendanceStatus.late => 'late',
      };
}

AttendanceStatus parseAttendanceStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'present':
      return AttendanceStatus.present;
    case 'late':
      return AttendanceStatus.late;
    case 'absent':
    default:
      return AttendanceStatus.absent;
  }
}

/// Model for the `/users/{uid}` schema.
class UserSyncRecord {
  UserSyncRecord({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.collegeId,
    this.createdAt,
    this.dob,
    this.photoUrl,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? const <String, dynamic>{};

  final String uid;
  final String name;
  final String email;
  final String role;
  final String collegeId;
  final DateTime? createdAt;
  final String? dob; // ISO date string e.g. 2001-05-20
  final String? photoUrl;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toMap() {
    final now = createdAt ?? DateTime.now().toUtc();
    return _clean({
      'name': name,
      'email': email,
      'dob': dob,
      'photoUrl': photoUrl,
      'role': role,
      'collegeId': collegeId,
      'createdAt': _formatDateTime(now),
      ...extra,
    });
  }

  factory UserSyncRecord.fromJson(Map<String, dynamic> json, {String? fallbackUid}) {
    return UserSyncRecord(
      uid: (json['uid'] ?? fallbackUid ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'student') as String,
      collegeId: (json['collegeId'] ?? '') as String,
      photoUrl: json['photoUrl'] as String?,
      dob: json['dob'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      extra: Map<String, dynamic>.from(json['extra'] as Map? ?? const <String, dynamic>{}),
    );
  }
}

/// Model for `/attendance/{attendanceId}`.
class AttendanceSyncRecord {
  AttendanceSyncRecord({
    this.attendanceId,
    required this.userId,
    required this.collegeId,
    required this.status,
    DateTime? timestamp,
    Map<String, dynamic>? extra,
  })  : timestamp = (timestamp ?? DateTime.now().toUtc()),
        extra = extra ?? const <String, dynamic>{};

  final String? attendanceId;
  final String userId;
  final String collegeId;
  final AttendanceStatus status;
  final DateTime timestamp;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toMap() => _clean({
        'userId': userId,
        'collegeId': collegeId,
        'timestamp': _formatDateTime(timestamp),
        'status': status.value,
        ...extra,
      });

  factory AttendanceSyncRecord.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return AttendanceSyncRecord(
      attendanceId: (json['attendanceId'] ?? fallbackId) as String?,
      userId: (json['userId'] ?? '') as String,
      collegeId: (json['collegeId'] ?? '') as String,
  status: parseAttendanceStatus((json['status'] ?? 'absent') as String),
      timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now().toUtc(),
      extra: Map<String, dynamic>.from(json['extra'] as Map? ?? const <String, dynamic>{}),
    );
  }
}

/// Model for `/library/{transactionId}`.
class LibrarySyncRecord {
  LibrarySyncRecord({
    this.transactionId,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    DateTime? issuedAt,
    this.returnedAt,
    Map<String, dynamic>? extra,
  })  : issuedAt = issuedAt ?? DateTime.now().toUtc(),
        extra = extra ?? const <String, dynamic>{};

  final String? transactionId;
  final String userId;
  final String bookId;
  final String bookTitle;
  final DateTime issuedAt;
  final DateTime? returnedAt;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toMap() => _clean({
        'userId': userId,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'issuedAt': _formatDateTime(issuedAt),
        'returnedAt': returnedAt != null ? _formatDateTime(returnedAt!) : null,
        ...extra,
      });

  factory LibrarySyncRecord.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return LibrarySyncRecord(
      transactionId: (json['transactionId'] ?? fallbackId) as String?,
      userId: (json['userId'] ?? '') as String,
      bookId: (json['bookId'] ?? '') as String,
      bookTitle: (json['bookTitle'] ?? '') as String,
      issuedAt: _parseDateTime(json['issuedAt']) ?? DateTime.now().toUtc(),
      returnedAt: _parseDateTime(json['returnedAt']),
      extra: Map<String, dynamic>.from(json['extra'] as Map? ?? const <String, dynamic>{}),
    );
  }
}

/// Model for `/documents/{docId}`.
class DocumentSyncRecord {
  DocumentSyncRecord({
    this.docId,
    required this.userId,
    required this.type,
    required this.fileUrl,
    DateTime? uploadedAt,
    Map<String, dynamic>? extra,
  })  : uploadedAt = uploadedAt ?? DateTime.now().toUtc(),
        extra = extra ?? const <String, dynamic>{};

  final String? docId;
  final String userId;
  final String type;
  final String fileUrl;
  final DateTime uploadedAt;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toMap() => _clean({
        'userId': userId,
        'type': type,
        'fileUrl': fileUrl,
        'uploadedAt': _formatDateTime(uploadedAt),
        ...extra,
      });

  factory DocumentSyncRecord.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return DocumentSyncRecord(
      docId: (json['docId'] ?? fallbackId) as String?,
      userId: (json['userId'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      fileUrl: (json['fileUrl'] ?? '') as String,
      uploadedAt: _parseDateTime(json['uploadedAt']) ?? DateTime.now().toUtc(),
      extra: Map<String, dynamic>.from(json['extra'] as Map? ?? const <String, dynamic>{}),
    );
  }
}

/// Model for `/colleges/{collegeId}`.
class CollegeSyncRecord {
  CollegeSyncRecord({
    required this.collegeId,
    required this.name,
    required this.eventLimit,
    required this.monthlyEventCount,
    required this.resetDate,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? const <String, dynamic>{};

  final String collegeId;
  final String name;
  final int eventLimit;
  final int monthlyEventCount;
  final DateTime resetDate;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toMap() => _clean({
        'name': name,
        'eventLimit': eventLimit,
        'monthlyEventCount': monthlyEventCount,
        'resetDate': _formatDate(resetDate),
        ...extra,
      });

  factory CollegeSyncRecord.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return CollegeSyncRecord(
      collegeId: (json['collegeId'] ?? fallbackId ?? '') as String,
      name: (json['name'] ?? '') as String,
      eventLimit: (json['eventLimit'] as num?)?.toInt() ?? 0,
      monthlyEventCount: (json['monthlyEventCount'] as num?)?.toInt() ?? 0,
      resetDate: _parseDate(json['resetDate']) ?? DateTime.now().toUtc(),
      extra: Map<String, dynamic>.from(json['extra'] as Map? ?? const <String, dynamic>{}),
    );
  }
}

String _formatDateTime(DateTime value) => value.toUtc().toIso8601String();

String _formatDate(DateTime value) {
  final utc = value.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${utc.year}-${two(utc.month)}-${two(utc.day)}';
}

DateTime? _parseDateTime(Object? raw) {
  if (raw == null) return null;
  if (raw is Timestamp) return raw.toDate().toUtc();
  if (raw is DateTime) return raw.toUtc();
  if (raw is int) {
    // Treat as milliseconds since epoch
    return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
  }
  if (raw is String && raw.isNotEmpty) {
    try {
      return DateTime.parse(raw).toUtc();
    } catch (_) {
      return null;
    }
  }
  return null;
}

DateTime? _parseDate(Object? raw) {
  final dt = _parseDateTime(raw);
  if (dt == null) return null;
  return DateTime.utc(dt.year, dt.month, dt.day);
}

Map<String, dynamic> _clean(Map<String, dynamic> input) {
  final result = <String, dynamic>{};
  input.forEach((key, value) {
    if (value != null) {
      result[key] = value;
    }
  });
  return result;
}

# Supabase ↔ Firebase Sync Guide

This codebase now includes a lightweight synchronization layer (`SupabaseSyncService`) that mirrors
all payloads expected from Supabase Edge Functions into Firebase Cloud Firestore. The goal is to
ensure that any off-device updates immediately materialize in the Firebase console using the
required schemas.

## Collections covered

The following top-level collections are created/updated by the orchestrator:

1. `users/{uid}`
2. `attendance/{attendanceId}`
3. `library/{transactionId}`
4. `documents/{docId}`
5. `colleges/{collegeId}`

The field layout for each collection matches the specification provided by product:

```jsonc
// 1. users/{uid}
{
  "uid": "john@example.com",
  "name": "John Doe",
  "email": "john@example.com",
  "dob": "2001-05-20",
  "photoUrl": "https://supabase.co/storage/v1/object/public/users/john.jpg",
  "role": "student",
  "collegeId": "abc-college",
  "createdAt": "2025-09-03T12:00:00Z"
}

// 2. attendance/{attendanceId}
{
  "attendanceId": "attendance-demo-1",
  "userId": "john@example.com",
  "collegeId": "abc-college",
  "timestamp": "2025-09-03T09:15:00Z",
  "status": "present",
  "classId": "MATH101",
  "sessionId": "session-123", // optional metadata from clients
  "source": "edge-function"   // optional metadata from clients
}

// 3. library/{transactionId}
{
  "transactionId": "lib-demo-1",
  "userId": "john@example.com",
  "bookId": "lib-12345",
  "bookTitle": "Data Structures in C",
  "issuedAt": "2025-09-03T10:00:00Z",
  "returnedAt": null,
  "status": "issued",
  "dueDate": "2025-09-10T10:00:00Z"
}

// 4. documents/{docId}
{
  "docId": "doc-demo-1",
  "userId": "john@example.com",
  "type": "hallticket",
  "fileUrl": "https://supabase.co/storage/v1/object/public/documents/john-hallticket.pdf",
  "uploadedAt": "2025-09-03T11:30:00Z",
  "hidden": false,
  "issuedBy": "admin-123" // optional
}

// 5. colleges/{collegeId}
{
  "collegeId": "abc-college",
  "name": "ABC College of Engineering",
  "eventLimit": 10,
  "monthlyEventCount": 7,
  "resetDate": "2025-09-01"
}
```

Optional metadata (e.g., `classId`, `issuedBy`, `hidden`) can be provided by callers. Unknown keys
are merged transparently so the schema remains forward compatible.

## Orchestrator API surface

All Supabase-triggered writes should call into the new service located at
`lib/services/supabase_sync_service.dart`.

| Method | Purpose |
| --- | --- |
| `SupabaseSyncService.upsertUser(UserSyncRecord record)` | Creates/updates a user document |
| `SupabaseSyncService.recordAttendance(AttendanceSyncRecord record)` | Appends or upserts an attendance row |
| `SupabaseSyncService.recordLibraryTransaction(LibrarySyncRecord record)` | Upserts a library transaction |
| `SupabaseSyncService.upsertDocument(DocumentSyncRecord record)` | Creates or updates a user document record |
| `SupabaseSyncService.upsertCollege(CollegeSyncRecord record)` | Creates/updates a college configuration |

Each record type has a `.fromJson` factory to make it easy to bridge Supabase payloads:

```dart
final record = AttendanceSyncRecord.fromJson(payload);
await SupabaseSyncService.recordAttendance(record);
```

## Local seeding & verification

`CoreSeedService.seedDemoData()` seeds deterministic entries across all collections so you can
visually confirm the schemas in the Firebase console or during automated tests.

```dart
await CoreSeedService.seedDemoData();
```

The helper is idempotent and can be wired into a debug-only button or executed manually from a test
harness.

## Runtime services that mirror the schema

The in-app service layer now mirrors the same structure when users interact with the app:

- `AttendanceService.recordAttendance` mirrors every event into `/attendance` in addition to the
  existing aggregates and mirror collection used by the UI.
- `LibraryService.createIssue` writes into `/library` with the required canonical fields.
- `DocumentsService.uploadDocumentForUser` creates `/documents` entries with the prescribed layout.
- `CollegesService.upsertCollege` ensures admin flows can manage `/colleges` entries using the
  standard schema.

All of these helpers rely on `SupabaseSyncService` under the hood, guaranteeing the schema stays in
lock-step whether the change originated from Supabase or from a Flutter client.

## Required indexes

To support fast analytics and reporting, add the following composite indexes in Firestore if you
haven't already:

1. `attendance`: `collegeId ASC`, `timestamp DESC`
2. `library`: `userId ASC`, `status ASC`, `issuedAt DESC`
3. `documents`: `userId ASC`, `uploadedAt DESC`

## Next steps

- Expose small HTTP/Cloud Function endpoints that Supabase Edge Functions can call, or import this
  Dart package directly into your function runtime.
- Add integration tests that invoke the orchestrator with representative payloads to validate the
  Firestore projections.
- Once custom claims are provisioned, tighten security rules so only privileged roles can mutate
  the canonical collections (`attendance`, `library`, `documents`, `colleges`).

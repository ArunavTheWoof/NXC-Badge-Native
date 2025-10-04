# Service & UI Overview

This document summarizes the key service-layer utilities and UI touchpoints that were added or
upgraded during the recent moderation pass. Use it as a quick reference when wiring new features or
triggering Supabase-driven updates.

## Attendance Service (`lib/services/attendance_service.dart`)

### Responsibilities
- Maintain granular attendance records in `/attendanceRecords` and `/attendanceAgg`.
- Mirror per-user aggregates into `/attendanceMirrors/{userId}` for lightweight dashboard reads.
- Stream every attendance event into the canonical `/attendance/{attendanceId}` collection via
  `SupabaseSyncService.recordAttendance` so external systems stay in sync.

### Key APIs
- `ensureUserAggregate(userId)` – bootstrap the aggregate and mirror docs.
- `recordAttendance(...)` – write the session record, update aggregates, and publish the
  Supabase-aligned document.
- `mirrorUserAggregate(...)` – refresh the simplified mirror doc used by the student dashboard.
- `seedAttendanceForUser(...)`, `seedExactPercentages(...)`, `quickDemoSeed(...)` – handy for test
  fixtures. Adjust target percentages using the `classPercentTargets` map.

### Adjusting Percentages
```
await AttendanceService.seedExactPercentages(
  userId: 'john@example.com',
  classPercentTargets: {
    'MATH101': 69,
    'SCI101': 70,
  },
  totalTarget: 100,
);
```
The helper tops up sessions until the configured totals are reached, then re-mirrors the aggregate.

## Classes Service (`lib/services/classes_service.dart`)

- `createClass(...)` – create a class shell with subjects and teacher IDs.
- `enrollStudent(...)` – transactional update that keeps both `/classes/{classId}` and
  `/users/{uid}` in sync (students list + `classesEnrolled`).
- `fetchClassesForUser(userId)` – returns the documents consumed by the dynamic student dashboard.

## Library Service (`lib/services/library_service.dart`)

- `createIssue(...)` – records issues inside the canonical `/library/{transactionId}` collection and
  attaches metadata (`status`, `dueDate`, `librarianId`).
- `markReturned(issueId)` – updates the transaction with `returnedAt` + `status`.
- `activeIssuesStream(userId)` – powers the librarian dashboard tab for real-time monitoring.

All library writes route through `SupabaseSyncService.recordLibraryTransaction`, guaranteeing the
schema matches the Supabase specification.

## Documents Service (`lib/services/documents_service.dart`)

- `uploadDocumentForUser(...)` – main entry point for storing hall tickets, ID cards, etc. directly
  under `/documents/{docId}`.
- `issueDocument(...)` – friendly alias that mirrors previous “issue” terminology.
- `fetchIssuedForUser(...)` – used by dashboards to pull visible documents; supports hidden docs for
  administrative review.
- `hideIssuedDoc(...)` / `unhideIssuedDoc(...)` – toggle visibility instead of hard deleting.

## Colleges Service (`lib/services/colleges_service.dart`)

- `upsertCollege(...)` – create or update the `/colleges/{collegeId}` record with event limits and
  reset schedules.
- `incrementMonthlyEventCount(...)` and `resetMonthlyEventCount(...)` – utility helpers for quota
  management workflows.

## Supabase Sync (`lib/services/supabase_sync_service.dart`)

A dedicated orchestrator that accepts strongly typed records (`UserSyncRecord`, `AttendanceSyncRecord`,
`LibrarySyncRecord`, `DocumentSyncRecord`, `CollegeSyncRecord`). Every service listed above uses it
internally so Firestore mirrors Supabase updates exactly.

Refer to [`SUPABASE_INTEGRATION.md`](../SUPABASE_INTEGRATION.md) for the full schema reference and
index recommendations.

## UI Highlights

- **Student Dashboard** now auto-loads classes via `ClassesService.fetchClassesForUser` and keeps a
  live mirror of attendance data. The fallback subject tiles remain for unenrolled users.
- **Librarian Dashboard** exposes an “Active Issues” tab powered by `LibraryService.activeIssuesStream`
  with a one-tap return action.
- **Admin Create Class** screen hooks into `ClassesService.createClass` so newly defined classes are
  wired immediately into the enrollment flows.

These improvements ensure that any Supabase Edge Function or on-device action writes identical
records, allowing you to inspect the Firebase console with confidence.

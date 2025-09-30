# Firestore Security Rules Recommendations (Draft)

These recommendations cover the collections introduced: users, attendanceSessions, attendanceRecords, attendanceAgg, attendance (mirror), classes, libraryIssues, documents, issuedDocs.

## Role Determination
Roles stored in `users/{uid}`:
```
roles: ["Admin", "Librarian", "Student", "Gatekeeper", "Organizer"],
currentRole: "Student"
```
Use custom claims (preferred for production) or read user doc in client then enforce in rules via document-based role (less secure if not coupled with claims). For stronger guarantees, set Firebase Auth custom claims during signup provisioning and reference them with `request.auth.token.role`.

## Collections Overview
| Collection | Purpose | Primary Writers | Primary Readers |
|------------|---------|-----------------|-----------------|
| users | Profile & role metadata | Server / user (self limited) | User (self), Admin (all) |
| attendanceSessions | Class/session creation | Admin/Teacher/Gatekeeper | Admin/Teacher/Gatekeeper |
| attendanceRecords | Individual attendance event | System (cloud function / secure client) | Admin/Teacher (by class) |
| attendanceAgg | Aggregated per-user stats | System / attendance logic | User (self), Admin |
| attendance (mirror) | Simplified per-user map | System | User (self), Admin |
| classes | Class definitions & membership | Admin | Admin, Teacher (assigned), Student (enrolled minimal fields) |
| libraryIssues | Book issue tracking | Librarian | Librarian, User (self subset) |
| documents | Base document definitions (e.g. hall tickets) | Admin | Admin, (maybe Student filtered) |
| issuedDocs | Instances of docs issued to users | Admin (issuer) | User (own docs), Admin |

## Rule Strategy
1. Use custom claims for coarse allow/deny: `isAdmin`, `isLibrarian`, `isGatekeeper`, `isOrganizer`, `isTeacher` (if needed).
2. Use document ownership for fine-grain (e.g., `resource.data.userId == request.auth.uid`).
3. Restrict writes to whitelisted fields; reject client attempts to mutate server-managed counters or timestamps.
4. Enforce value constraints (status enum, size of arrays, boolean types) using rule expressions.

## Example Rule Snippets (Pseudo-Rules)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function hasRole(r) { return request.auth != null && request.auth.token[r] == true; }
    function isSelf(uid) { return request.auth != null && request.auth.uid == uid; }

    match /users/{userId} {
      allow read: if isSelf(userId) || hasRole('isAdmin');
      allow update: if isSelf(userId) && !("roles" in request.resource.data) && !("currentRole" in request.resource.data);
      allow create: if request.auth != null; // but prefer server
      allow delete: if false; // disallow direct deletion
    }

    match /classes/{classId} {
      allow create, update, delete: if hasRole('isAdmin');
      allow read: if request.auth != null; // optionally refine to enrolled-only
    }

    match /attendanceSessions/{sessionId} {
      allow create: if hasRole('isAdmin') || hasRole('isGatekeeper') || hasRole('isTeacher');
      allow read: if hasRole('isAdmin') || hasRole('isTeacher') || hasRole('isGatekeeper');
      allow delete: if false;
    }

    match /attendanceRecords/{recordId} {
      allow create: if hasRole('isAdmin') || hasRole('isGatekeeper') || hasRole('isTeacher');
      allow read: if hasRole('isAdmin') || hasRole('isTeacher');
      allow delete, update: if false;
    }

    match /attendanceAgg/{userId} {
      allow read: if isSelf(userId) || hasRole('isAdmin');
      allow write: if false; // only via backend or privileged context
    }

    match /attendance/{userId} { // mirror
      allow read: if isSelf(userId) || hasRole('isAdmin');
      allow write: if false; // system only
    }

    match /libraryIssues/{issueId} {
      allow create, update: if hasRole('isLibrarian') || hasRole('isAdmin');
      allow read: if hasRole('isLibrarian') || hasRole('isAdmin') || (resource.data.userId == request.auth.uid);
      allow delete: if false;
    }

    match /documents/{docId} {
      allow create, update, delete: if hasRole('isAdmin');
      allow read: if hasRole('isAdmin'); // or broaden for published types
    }

    match /issuedDocs/{id} {
      allow create: if hasRole('isAdmin');
      allow update: if hasRole('isAdmin'); // hide/unhide
      allow read: if (resource.data.userId == request.auth.uid) || hasRole('isAdmin');
      allow delete: if false;
    }
  }
}
```

## Validation Suggestions
- Enforce status enum in `libraryIssues`: `request.resource.data.status in ["issued","returned"]`.
- Limit subjects array length: `request.resource.data.subjects.size() <= 20`.
- Meta size: `meta` map keys limited: `request.resource.data.meta.keys().size() <= 25`.
- Prevent user from escalating roles (deny writes containing `roles` / `currentRole`).

## Indexing Recommendations
- `issuedDocs`: composite index on (userId, hidden, issuedAt desc)
- `libraryIssues`: index on (userId, status, issueDate desc)
- `attendanceRecords`: index on (userId, classId, timestamp desc) if queried

## Logging & Auditing
- Consider Cloud Functions to log high-risk mutations (role changes, document issuance).
- Attach `issuedBy`, `createdBy` consistently for traceability.

## Hardening Next Steps
1. Move seeding and aggregate writes to backend (Cloud Functions / Admin SDK) for stronger trust boundaries.
2. Add rate limiting with Firebase App Check + analytics anomaly detection.
3. Integrate custom claims setter at signup to mirror Firestore roles.
4. Add a Cloud Function to purge or archive old attendanceRecords beyond retention.

---
This file is a draft foundation; refine based on actual UI query patterns and performance testing.

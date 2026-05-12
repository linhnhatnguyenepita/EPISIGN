# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EPISIGN is a SwiftUI iOS attendance-signing application for EPITA school. It replaces manual presence sheets with NFC-based verification. The app has two distinct user roles — **Student** and **Teacher** — each with a separate flow.

### How It Works

**Teacher flow (presence session setup)**
1. Teacher logs in with a teacher account.
2. Teacher opens the lecture they are currently running.
3. Teacher taps "Start signing" and scans an NFC tag physically placed in the classroom.
4. The app writes a **temporary session ID** to the NFC tag. This ID expires after **10 minutes**, after which no more student check-ins are accepted for that session.

**Student flow (presence verification)**
1. Student logs in with a student account.
2. Student opens the lecture they are attending.
3. The app displays an NFC prompt icon — the student taps their phone against the NFC tag in the classroom.
4. The app reads the session ID from the tag, sends it to the backend, and the backend validates:
   - The session ID matches the active lecture.
   - The session ID has not expired (< 10 minutes since the teacher wrote it).
   - The student is enrolled in that lecture.
   - The student has not already checked in.
5. On success, the presence is recorded and the student sees a confirmation.

### Technical Architecture

**Authentication**
- Two account types: `student` and `teacher`, distinguished by a role field returned at login.
- After login the app stores an auth token (e.g. JWT) used for all API calls.
- The root view switches between `StudentRootView` and `TeacherRootView` based on the decoded role.

**NFC**
- Uses Apple's `CoreNFC` framework (`NFCNDEFReaderSession` for reading, `NFCNDEFReaderSession` with write support for writing).
- Teacher write: encodes a UUID-based session token as an NDEF Text record onto the tag.
- Student read: reads the NDEF payload, extracts the session token, and POSTs it to the backend.
- NFC sessions are one-shot (open → scan → close); the app re-opens a session each time.

**Session ID & expiry**
- The session ID is a short-lived UUID generated server-side when the teacher opens the signing window.
- Expiry is enforced **server-side** (10-minute TTL). The NFC tag itself holds no expiry — it just stores the token string.
- The teacher's app writes the token to the tag; the token is invalidated by the backend after 10 minutes regardless of what is on the tag.

**Backend: Firebase**

Firebase covers all backend needs for this project. No dedicated server is required.

| Firebase service | Role in EPISIGN |
|-----------------|-----------------|
| **Firebase Auth** | Email/password login; a custom claim (`role: "student" \| "teacher"`) is set on the account at creation, so the app knows which UI to show after login |
| **Cloud Firestore** | Stores lectures, active sessions, and presence records |
| **Cloud Functions** | Enforces server-side business logic (session creation, expiry check, duplicate check-in prevention) |
| **Firestore Security Rules** | Ensures clients cannot read or write sensitive documents directly — all writes go through Functions |

**Why Cloud Functions are required (not optional)**

The 10-minute expiry must be enforced server-side. If the student's app reads the session document from Firestore and checks the timestamp itself, a motivated student could manipulate that logic. Cloud Functions run on Google's servers, not the student's device, so the expiry check is trustworthy.

Two callable Cloud Functions replace the REST API:

- `startSession(lectureId)` — called by the teacher's app; creates a session document in Firestore with `{ sessionId, lectureId, createdAt, createdBy }` and returns the `sessionId` to write to the NFC tag.
- `checkin(sessionId, lectureId)` — called by the student's app after reading the NFC tag; the Function:
  1. Fetches the session document.
  2. Rejects if `now - createdAt > 10 minutes`.
  3. Rejects if the student is not enrolled in the lecture.
  4. Rejects if a presence record for this student+lecture already exists (duplicate check-in).
  5. On success, writes a presence record atomically via a Firestore transaction.

**Firestore data model**

```
/lectures/{lectureId}
  title, teacherId, studentIds[], scheduledAt

/sessions/{sessionId}
  lectureId, createdBy (teacherId), createdAt, expiresAt

/presence/{lectureId}/records/{studentId}
  studentId, checkedInAt, sessionId
```

**SwiftUI structure**
- `EPISIGNApp` — app entry, decides which root view to show after auth
- `AuthViewModel` — handles login, token storage (Keychain), role decoding
- `LectureListView` / `LectureListViewModel` — fetches and displays the user's lectures
- `TeacherSigningView` — opens NFC write session, calls `/sessions/start`, writes token to tag
- `StudentCheckinView` — opens NFC read session, reads token, calls `/sessions/checkin`

**Data flow**
```
Teacher:  Login → fetch lectures → start session (API) → get sessionId → write to NFC tag
Student:  Login → fetch lectures → tap NFC tag → read sessionId → POST checkin (API) → confirmed
```

## Build & Run

Build and run via Xcode (open `EPISIGN.xcodeproj`) or from the command line:

```bash
# Build
xcodebuild -project EPISIGN.xcodeproj -scheme EPISIGN -sdk iphonesimulator build

# Run on simulator
xcodebuild -project EPISIGN.xcodeproj -scheme EPISIGN -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

No test targets exist yet. When added, run them with:

```bash
xcodebuild test -project EPISIGN.xcodeproj -scheme EPISIGN -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture
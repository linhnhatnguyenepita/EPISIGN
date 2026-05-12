# EPISIGN - Todo List

## Phase 1: Infrastructure & Authentication
- [x] Initialize Firebase project and add `GoogleService-Info.plist`
- [ ] Integrate Firebase SDKs via SPM (Auth, Firestore, Functions) ← **À faire dans Xcode**
- [x] Implement `AuthViewModel.swift` (Login/Logout logic)
- [x] Create `LoginView.swift` with premium design
- [x] Setup Role-based routing in `EPISIGNApp.swift`

## Phase 2: Backend Development (Firebase)
- [ ] Initialize Firebase CLI → `npm install -g firebase-tools && firebase login` ← **À faire**
- [x] Implement `startSession` Cloud Function (Node.js)
- [x] Implement `checkin` Cloud Function (Node.js)
- [x] Configure Firestore Security Rules
- [ ] Deploy functions → `cd functions && npm install && firebase deploy` ← **À faire**
- [ ] Run seed script → `node seed.js` (après avoir téléchargé serviceAccountKey.json) ← **À faire**

## Phase 3: Teacher Flow (NFC Write)
- [x] Implement `TeacherLectureListView`
- [x] Create `TeacherSigningView`
- [x] Implement `NFCWriterService` (CoreNFC) to write session token to tag
- [x] Connect "Start Signing" button to `startSession` API

## Phase 4: Student Flow (NFC Read)
- [x] Implement `StudentLectureListView`
- [x] Create `StudentCheckinView`
- [x] Implement `NFCReaderService` (CoreNFC) to read session token from tag
- [x] Connect successful NFC read to `checkin` API

## Phase 5: UI/UX & Polish
- [x] Add custom styling (shadows, gradients, typography, dark theme)
- [x] Implement micro-animations for NFC scanning (pulse rings)
- [x] Add Haptic Feedback for success/error
- [x] Robust error handling and connectivity checks

## Phase 6: Xcode Setup (Manuel — à faire dans Xcode)
- [ ] Add Firebase via SPM: File → Add Package Dependencies
      URL: https://github.com/firebase/firebase-ios-sdk
      Packages: FirebaseAuth, FirebaseFirestore, FirebaseFunctions
- [ ] Add `GoogleService-Info.plist` to the Xcode target (drag & drop dans EPISIGN/)
- [ ] Add NFC entitlement: Signing & Capabilities → + → Near Field Communication Tag Reading
- [ ] Add `NFCReaderUsageDescription` in Info.plist:
      "EPISIGN utilise le NFC pour lire les tags de présence en salle de cours."

## Phase 7: Testing & Validation
- [ ] Unit tests for `AuthViewModel`
- [ ] Integration tests for Cloud Functions (using Emulator)
- [ ] Physical device testing for NFC lifecycle

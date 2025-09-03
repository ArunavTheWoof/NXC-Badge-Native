# Firebase Integration Documentation

## Overview
This Flutter app is now fully integrated with Firebase, providing authentication, cloud database, file storage, and analytics capabilities.

## Firebase Services Integrated

### 1. Firebase Authentication
- Email/password authentication
- User management
- Role-based access control

### 2. Cloud Firestore
- NoSQL database for app data
- Real-time data synchronization
- Offline support

### 3. Firebase Storage
- File upload and download
- Image and document storage
- Progress tracking

### 4. Firebase Analytics
- User behavior tracking
- Custom events
- Performance monitoring

## Project Structure

```
lib/
├── services/
│   ├── firebase_service.dart      # Main Firebase service
│   ├── auth_service.dart          # Authentication service
│   ├── firestore_service.dart     # Database operations
│   └── storage_service.dart       # File storage operations
├── config/
│   └── firebase_config.dart       # Configuration constants
└── examples/
    └── firebase_auth_example.dart  # Example authentication screen
```

## Setup Instructions

### 1. Google Services Configuration File Placement

**For Android:**
Place your `google-services.json` file in:
```
android/app/google-services.json
```

**For iOS:**
Place your `GoogleService-Info.plist` file in:
```
ios/Runner/GoogleService-Info.plist
```

### 2. SHA Certificate Setup (Android)

1. **Debug SHA-1 (for development):**
   ```bash
   keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
   ```

2. **Release SHA-1 (for production):**
   ```bash
   keytool -list -v -alias <your-key-alias> -keystore <path-to-your-keystore>
   ```

3. Add these SHA-1 fingerprints to your Firebase project:
   - Go to Firebase Console > Project Settings > General
   - Scroll down to "Your apps" section
   - Click on your Android app
   - Add the SHA-1 certificates

### 3. Firebase Project Configuration

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Google Analytics (recommended)

2. **Add Android App:**
   - Click "Add app" > Android
   - Package name: `com.example.test_app1` (or your custom package)
   - Download `google-services.json`

3. **Add iOS App (if needed):**
   - Click "Add app" > iOS
   - Bundle ID: `com.example.testApp1` (or your custom bundle ID)
   - Download `GoogleService-Info.plist`

4. **Enable Firebase Services:**
   - **Authentication:** Go to Authentication > Sign-in method > Enable Email/Password
   - **Firestore:** Go to Firestore Database > Create database
   - **Storage:** Go to Storage > Get started
   - **Analytics:** Automatically enabled if selected during project creation

### 4. Firestore Security Rules

Set up basic security rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Classes - teachers can manage their classes
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.teacherId == request.auth.uid);
    }
    
    // Students - read access for authenticated users, write for admins/teachers
    match /students/{studentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Other collections with similar patterns...
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Storage Security Rules

Set up Storage security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Usage Examples

### 1. Initialize Firebase (Already done in main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const MyApp());
}
```

### 2. Authentication

```dart
// Sign up
await AuthService.createUserWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
  role: 'student',
);

// Sign in
await AuthService.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await AuthService.signOut();
```

### 3. Firestore Operations

```dart
// Create a class
await FirestoreService.createClass(
  className: 'Mathematics 101',
  classCode: 'MATH101',
  subject: 'Mathematics',
  description: 'Basic mathematics course',
  teacherId: 'teacher_id',
  teacherName: 'Dr. Smith',
);

// Get classes for a teacher
Stream<QuerySnapshot> classes = FirestoreService.getClassesForTeacher('teacher_id');

// Add student to class
await FirestoreService.addStudentToClass(
  classId: 'class_id',
  studentId: 'student_id',
  studentName: 'Jane Doe',
  studentEmail: 'jane@example.com',
  rollNumber: '2023001',
);
```

### 4. File Storage

```dart
// Upload profile image
String imageUrl = await StorageService.uploadProfileImage(imageFile, userId);

// Upload document
String documentUrl = await StorageService.uploadDocument(documentFile, documentId);

// Delete file
await StorageService.deleteFile('path/to/file');
```

### 5. Analytics

```dart
// Log custom event
await FirebaseService.logEvent('class_created', {
  'class_name': 'Mathematics 101',
  'teacher_id': 'teacher_id',
});

// Set user property
await FirebaseService.setUserProperty('user_role', 'student');
```

## Testing Firebase Integration

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test authentication:**
   - Navigate to the Firebase Auth Example screen
   - Try creating a new account
   - Try signing in with existing credentials
   - Check Firebase Console > Authentication to see registered users

3. **Test Firestore:**
   - Create some data using the app
   - Check Firebase Console > Firestore to see the data

4. **Test Storage:**
   - Upload some files using the app
   - Check Firebase Console > Storage to see uploaded files

## Data Models

### User Document
```dart
{
  'uid': 'user_id',
  'email': 'user@example.com',
  'displayName': 'John Doe',
  'role': 'student', // admin, teacher, student, librarian, gatekeeper, organiser
  'createdAt': Timestamp,
  'lastLoginAt': Timestamp,
  'isActive': true,
}
```

### Class Document
```dart
{
  'className': 'Mathematics 101',
  'classCode': 'MATH101',
  'subject': 'Mathematics',
  'description': 'Basic mathematics course',
  'teacherId': 'teacher_id',
  'teacherName': 'Dr. Smith',
  'studentCount': 25,
  'isActive': true,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
}
```

### Student Document
```dart
{
  'classId': 'class_id',
  'studentId': 'student_id',
  'studentName': 'Jane Doe',
  'studentEmail': 'jane@example.com',
  'rollNumber': '2023001',
  'isActive': true,
  'createdAt': Timestamp,
}
```

## Next Steps

1. **Customize the UI:** Integrate Firebase services into your existing screens
2. **Add more features:** Implement real-time updates, push notifications
3. **Security:** Review and update Firestore and Storage security rules
4. **Testing:** Add unit tests for Firebase services
5. **Performance:** Monitor app performance using Firebase Performance Monitoring

## Support

For additional help:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## Common Issues and Solutions

### 1. Google Services Plugin Not Applied
**Error:** "google-services plugin not applied"
**Solution:** Ensure you've added the plugin to both project-level and app-level build.gradle files

### 2. SHA Certificate Mismatch
**Error:** Authentication fails on release builds
**Solution:** Add release SHA-1 certificate to Firebase project

### 3. Network Security Policy (Android 9+)
**Error:** Network requests fail
**Solution:** Add network security config to allow cleartext traffic for development

### 4. iOS Build Issues
**Error:** iOS build fails after adding Firebase
**Solution:** Ensure GoogleService-Info.plist is properly added to iOS project in Xcode

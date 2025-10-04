/// Configuration options for Firebase
class FirebaseConfig {
  // Collection names
  static const String usersCollection = 'users';
  static const String classesCollection = 'classes';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance';
  static const String attendanceMirrorCollection = 'attendanceMirrors';
  static const String eventsCollection = 'events';
  static const String booksCollection = 'books';
  static const String borrowedBooksCollection = 'borrowed_books';
  static const String documentsCollection = 'documents';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String eventImagesPath = 'event_images';
  static const String bookCoversPath = 'book_covers';
  static const String documentsPath = 'documents';
  static const String qrCodesPath = 'qr_codes';
  static const String assignmentsPath = 'assignments';
  
  // User roles
  static const String adminRole = 'admin';
  static const String teacherRole = 'teacher';
  static const String studentRole = 'student';
  static const String librarianRole = 'librarian';
  static const String gatekeeperRole = 'gatekeeper';
  static const String organiserRole = 'organiser';
  
  // Document types
  static const String transcriptDocument = 'transcript';
  static const String certificateDocument = 'certificate';
  static const String idCardDocument = 'id_card';
  static const String recommendationDocument = 'recommendation';
  
  // Analytics events
  static const String loginEvent = 'login';
  static const String signupEvent = 'sign_up';
  static const String logoutEvent = 'logout';
  static const String fileUploadEvent = 'file_uploaded';
  static const String attendanceMarkedEvent = 'attendance_marked';
  static const String classCreatedEvent = 'class_created';
  static const String eventCreatedEvent = 'event_created';
  static const String bookIssuedEvent = 'book_issued';
  static const String documentIssuedEvent = 'document_issued';
  
  // Error messages
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String permissionError = 'You do not have permission to perform this action.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  
  // Success messages
  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account created successfully!';
  static const String dataUpdateSuccess = 'Data updated successfully!';
  static const String fileUploadSuccess = 'File uploaded successfully!';
}

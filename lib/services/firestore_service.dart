import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Firestore service for database operations
class FirestoreService {
  
  // Collection references
  static CollectionReference get users => FirebaseService.firestore.collection('users');
  static CollectionReference get classes => FirebaseService.firestore.collection('classes');
  static CollectionReference get students => FirebaseService.firestore.collection('students');
  static CollectionReference get attendance => FirebaseService.firestore.collection('attendance');
  static CollectionReference get events => FirebaseService.firestore.collection('events');
  static CollectionReference get books => FirebaseService.firestore.collection('books');
  static CollectionReference get borrowedBooks => FirebaseService.firestore.collection('borrowed_books');
  static CollectionReference get documents => FirebaseService.firestore.collection('documents');
  
  /// Generic method to add a document to any collection
  static Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['createdBy'] = FirebaseService.currentUserId;
      
      return await FirebaseService.firestore.collection(collection).add(data);
    } catch (e) {
      LogService.error('Error adding document to $collection', error: e);
      rethrow;
    }
  }
  
  /// Generic method to update a document in any collection
  static Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['updatedBy'] = FirebaseService.currentUserId;
      
      await FirebaseService.firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      LogService.error('Error updating document in $collection', error: e);
      rethrow;
    }
  }
  
  /// Generic method to delete a document from any collection
  static Future<void> deleteDocument(String collection, String docId) async {
    try {
      await FirebaseService.firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      LogService.error('Error deleting document from $collection', error: e);
      rethrow;
    }
  }
  
  /// Generic method to get a document from any collection
  static Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await FirebaseService.firestore.collection(collection).doc(docId).get();
    } catch (e) {
      LogService.error('Error getting document from $collection', error: e);
      rethrow;
    }
  }
  
  /// Generic method to get documents from any collection with query
  static Stream<QuerySnapshot> getDocuments(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    try {
      Query query = FirebaseService.firestore.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return query.snapshots();
    } catch (e) {
      LogService.error('Error getting documents from $collection', error: e);
      rethrow;
    }
  }
  
  // === Class Management ===
  
  /// Create a new class
  static Future<DocumentReference> createClass({
    required String className,
    required String classCode,
    required String subject,
    required String description,
    required String teacherId,
    required String teacherName,
  }) async {
    return await addDocument('classes', {
      'className': className,
      'classCode': classCode,
      'subject': subject,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentCount': 0,
      'isActive': true,
    });
  }
  
  /// Get classes for a specific teacher
  static Stream<QuerySnapshot> getClassesForTeacher(String teacherId) {
    return getDocuments('classes', queryBuilder: (query) {
      return query
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);
    });
  }
  
  // === Student Management ===
  
  /// Add student to a class
  static Future<DocumentReference> addStudentToClass({
    required String classId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String rollNumber,
  }) async {
    return await addDocument('students', {
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'rollNumber': rollNumber,
      'isActive': true,
    });
  }
  
  /// Get students for a specific class
  static Stream<QuerySnapshot> getStudentsForClass(String classId) {
    return getDocuments('students', queryBuilder: (query) {
      return query
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .orderBy('studentName');
    });
  }
  
  // === Attendance Management ===
  
  /// Mark attendance for a student
  static Future<DocumentReference> markAttendance({
    required String classId,
    required String studentId,
    required String studentName,
    required DateTime date,
    required bool isPresent,
    String? remarks,
  }) async {
    return await addDocument('attendance', {
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'date': Timestamp.fromDate(date),
      'isPresent': isPresent,
      'remarks': remarks,
    });
  }
  
  /// Get attendance for a specific class and date
  static Stream<QuerySnapshot> getAttendanceForClassAndDate(String classId, DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return getDocuments('attendance', queryBuilder: (query) {
      return query
          .where('classId', isEqualTo: classId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .orderBy('studentName');
    });
  }
  
  // === Event Management ===
  
  /// Create a new event
  static Future<DocumentReference> createEvent({
    required String eventName,
    required String description,
    required DateTime eventDate,
    required String location,
    required String organizerId,
    required String organizerName,
    String? imageUrl,
  }) async {
    return await addDocument('events', {
      'eventName': eventName,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'imageUrl': imageUrl,
      'attendeeCount': 0,
      'isActive': true,
    });
  }
  
  /// Get all active events
  static Stream<QuerySnapshot> getActiveEvents() {
    return getDocuments('events', queryBuilder: (query) {
      return query
          .where('isActive', isEqualTo: true)
          .orderBy('eventDate', descending: true);
    });
  }
  
  // === Library Management ===
  
  /// Add a new book to library
  static Future<DocumentReference> addBook({
    required String title,
    required String author,
    required String isbn,
    required String category,
    required int totalCopies,
    required String librarianId,
    String? description,
    String? imageUrl,
  }) async {
    return await addDocument('books', {
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'totalCopies': totalCopies,
      'availableCopies': totalCopies,
      'librarianId': librarianId,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': true,
    });
  }
  
  /// Issue a book to a student
  static Future<DocumentReference> issueBook({
    required String bookId,
    required String studentId,
    required String studentName,
    required DateTime issueDate,
    required DateTime dueDate,
    required String librarianId,
  }) async {
    // First, decrease available copies
    await updateDocument('books', bookId, {
      'availableCopies': FieldValue.increment(-1),
    });
    
    return await addDocument('borrowed_books', {
      'bookId': bookId,
      'studentId': studentId,
      'studentName': studentName,
      'issueDate': Timestamp.fromDate(issueDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'librarianId': librarianId,
      'isReturned': false,
    });
  }
  
  /// Return a book
  static Future<void> returnBook(String borrowedBookId, String bookId) async {
    // Update borrowed book record
    await updateDocument('borrowed_books', borrowedBookId, {
      'isReturned': true,
      'returnDate': FieldValue.serverTimestamp(),
    });
    
    // Increase available copies
    await updateDocument('books', bookId, {
      'availableCopies': FieldValue.increment(1),
    });
  }
  
  /// Get all books
  static Stream<QuerySnapshot> getAllBooks() {
    return getDocuments('books', queryBuilder: (query) {
      return query
          .where('isActive', isEqualTo: true)
          .orderBy('title');
    });
  }
  
  /// Get borrowed books for a student
  static Stream<QuerySnapshot> getBorrowedBooksForStudent(String studentId) {
    return getDocuments('borrowed_books', queryBuilder: (query) {
      return query
          .where('studentId', isEqualTo: studentId)
          .where('isReturned', isEqualTo: false)
          .orderBy('issueDate', descending: true);
    });
  }
  
  // === Document Management ===
  
  /// Issue a document to a student
  static Future<DocumentReference> issueDocument({
    required String documentType,
    required String studentId,
    required String studentName,
    required String purpose,
    required String adminId,
    required String adminName,
    String? documentUrl,
  }) async {
    return await addDocument('documents', {
      'documentType': documentType,
      'studentId': studentId,
      'studentName': studentName,
      'purpose': purpose,
      'adminId': adminId,
      'adminName': adminName,
      'documentUrl': documentUrl,
      'status': 'issued',
      'issueDate': FieldValue.serverTimestamp(),
    });
  }
  
  /// Get documents for a specific student
  static Stream<QuerySnapshot> getDocumentsForStudent(String studentId) {
    return getDocuments('documents', queryBuilder: (query) {
      return query
          .where('studentId', isEqualTo: studentId)
          .orderBy('issueDate', descending: true);
    });
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Storage service for handling file uploads and downloads
class StorageService {
  
  /// Upload file to Firebase Storage
  static Future<String> uploadFile({
    required String filePath,
    required File file,
    Function(double)? onProgress,
  }) async {
    try {
      // Create a reference to the file location
      Reference storageRef = FirebaseService.storage.ref().child(filePath);
      
      // Create upload task
      UploadTask uploadTask = storageRef.putFile(file);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Log analytics event
      await FirebaseService.logEvent('file_uploaded', {
        'file_path': filePath,
        'file_size': file.lengthSync(),
        'user_id': FirebaseService.currentUserId ?? '',
      });
      
      return downloadUrl;
    } catch (e) {
      LogService.error('Error uploading file', error: e);
      rethrow;
    }
  }
  
  /// Upload bytes data to Firebase Storage
  static Future<String> uploadBytes({
    required String filePath,
    required Uint8List data,
    String? contentType,
    Function(double)? onProgress,
  }) async {
    try {
      // Create a reference to the file location
      Reference storageRef = FirebaseService.storage.ref().child(filePath);
      
      // Create metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
      );
      
      // Create upload task
      UploadTask uploadTask = storageRef.putData(data, metadata);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Log analytics event
      await FirebaseService.logEvent('bytes_uploaded', {
        'file_path': filePath,
        'data_size': data.length,
        'user_id': FirebaseService.currentUserId ?? '',
      });
      
      return downloadUrl;
    } catch (e) {
      LogService.error('Error uploading bytes', error: e);
      rethrow;
    }
  }
  
  /// Delete file from Firebase Storage
  static Future<void> deleteFile(String filePath) async {
    try {
      Reference storageRef = FirebaseService.storage.ref().child(filePath);
      await storageRef.delete();
      
      // Log analytics event
      await FirebaseService.logEvent('file_deleted', {
        'file_path': filePath,
        'user_id': FirebaseService.currentUserId ?? '',
      });
    } catch (e) {
      LogService.error('Error deleting file', error: e);
      rethrow;
    }
  }
  
  /// Get download URL for a file
  static Future<String> getDownloadUrl(String filePath) async {
    try {
      Reference storageRef = FirebaseService.storage.ref().child(filePath);
      return await storageRef.getDownloadURL();
    } catch (e) {
      LogService.error('Error getting download URL', error: e);
      rethrow;
    }
  }
  
  /// Get file metadata
  static Future<FullMetadata> getFileMetadata(String filePath) async {
    try {
      Reference storageRef = FirebaseService.storage.ref().child(filePath);
      return await storageRef.getMetadata();
    } catch (e) {
      LogService.error('Error getting file metadata', error: e);
      rethrow;
    }
  }
  
  /// List files in a directory
  static Future<ListResult> listFiles(String directoryPath, {int maxResults = 100}) async {
    try {
      Reference storageRef = FirebaseService.storage.ref().child(directoryPath);
      return await storageRef.list(ListOptions(maxResults: maxResults));
    } catch (e) {
      LogService.error('Error listing files', error: e);
      rethrow;
    }
  }
  
  // === Specific upload methods for different file types ===
  
  /// Upload profile image
  static Future<String> uploadProfileImage(File imageFile, String userId) async {
    String filePath = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadFile(filePath: filePath, file: imageFile);
  }
  
  /// Upload event image
  static Future<String> uploadEventImage(File imageFile, String eventId) async {
    String filePath = 'event_images/$eventId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadFile(filePath: filePath, file: imageFile);
  }
  
  /// Upload book cover image
  static Future<String> uploadBookCover(File imageFile, String bookId) async {
    String filePath = 'book_covers/$bookId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadFile(filePath: filePath, file: imageFile);
  }
  
  /// Upload document file
  static Future<String> uploadDocument(File documentFile, String documentId) async {
    String extension = documentFile.path.split('.').last;
    String filePath = 'documents/$documentId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    return await uploadFile(filePath: filePath, file: documentFile);
  }
  
  /// Upload QR code image
  static Future<String> uploadQRCode(Uint8List qrCodeBytes, String identifier) async {
    String filePath = 'qr_codes/$identifier/${DateTime.now().millisecondsSinceEpoch}.png';
    return await uploadBytes(
      filePath: filePath,
      data: qrCodeBytes,
      contentType: 'image/png',
    );
  }
  
  /// Upload assignment file
  static Future<String> uploadAssignment(File assignmentFile, String classId, String studentId) async {
    String extension = assignmentFile.path.split('.').last;
    String filePath = 'assignments/$classId/$studentId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    return await uploadFile(filePath: filePath, file: assignmentFile);
  }
  
  /// Get file size in a human-readable format
  static String getFileSizeString(int bytes) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }
  
  /// Generate unique file path
  static String generateFilePath(String directory, String fileName) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String extension = fileName.split('.').last;
    return '$directory/$timestamp.$extension';
  }
}

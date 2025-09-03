import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';

/// Authentication service for handling user authentication
class AuthService {
  
  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Log analytics event
      await FirebaseService.logEvent('login', {
        'method': 'email_password',
        'user_id': userCredential.user?.uid ?? '',
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      LogService.error('Sign in error: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      LogService.error('Unexpected error during sign in', error: e);
      rethrow;
    }
  }
  
  /// Create account with email and password
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile
      await userCredential.user?.updateDisplayName(displayName);
      
      // Create user document in Firestore
      await createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
      );
      
      // Log analytics event
      await FirebaseService.logEvent('sign_up', {
        'method': 'email_password',
        'user_id': userCredential.user?.uid ?? '',
        'role': role,
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      LogService.error('Create user error: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      LogService.error('Unexpected error during user creation', error: e);
      rethrow;
    }
  }
  
  /// Create user document in Firestore
  static Future<void> createUserDocument({
    required String uid,
    required String email,
    required String displayName,
    required String role,
  }) async {
    try {
      await FirebaseService.firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      LogService.error('Error creating user document', error: e);
      rethrow;
    }
  }
  
  /// Update user's last login time
  static Future<void> updateLastLogin() async {
    try {
      if (FirebaseService.currentUserId != null) {
        await FirebaseService.firestore
            .collection('users')
            .doc(FirebaseService.currentUserId)
            .update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      LogService.warning('Error updating last login', error: e);
    }
  }
  
  /// Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (FirebaseService.currentUserId != null) {
        DocumentSnapshot doc = await FirebaseService.firestore
            .collection('users')
            .doc(FirebaseService.currentUserId)
            .get();
        
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      LogService.error('Error getting user data', error: e);
      return null;
    }
  }
  
  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email);
      
      // Log analytics event
      await FirebaseService.logEvent('password_reset_request', {
        'email': email,
      });
    } on FirebaseAuthException catch (e) {
      LogService.error('Password reset error: ${e.message}', error: e);
      rethrow;
    }
  }
  
  /// Sign out
  static Future<void> signOut() async {
    try {
      await FirebaseService.signOut();
      
      // Log analytics event
      await FirebaseService.logEvent('logout', {
        'user_id': FirebaseService.currentUserId ?? '',
      });
    } catch (e) {
      LogService.error('Sign out error', error: e);
      rethrow;
    }
  }
  
  /// Delete user account
  static Future<void> deleteAccount() async {
    try {
      String? userId = FirebaseService.currentUserId;
      
      // Delete user document from Firestore
      if (userId != null) {
        await FirebaseService.firestore.collection('users').doc(userId).delete();
      }
      
      // Delete Firebase Auth user
      await FirebaseService.currentUser?.delete();
      
      // Log analytics event
      await FirebaseService.logEvent('account_deleted', {
        'user_id': userId ?? '',
      });
    } catch (e) {
      LogService.error('Delete account error', error: e);
      rethrow;
    }
  }
}

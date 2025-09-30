import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';
import 'package:test_app1/services/attendance_service.dart';

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

      // Dev: seed exact sample attendance for showcase user
      await _maybeSeedSampleAttendance(userCredential.user);
      
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
    String? collegeId,
    List<String>? classesEnrolled,
    String? avatarUrl,
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
        collegeId: collegeId,
        classesEnrolled: classesEnrolled ?? const [],
        avatarUrl: avatarUrl,
      );

      // Initialize attendance aggregate doc
      await AttendanceService.ensureUserAggregate(userCredential.user!.uid);
      
      // Log analytics event
      await FirebaseService.logEvent('sign_up', {
        'method': 'email_password',
        'user_id': userCredential.user?.uid ?? '',
        'role': role,
      });

      // Dev: also seed for showcase user if matching ID/email
      await _maybeSeedSampleAttendance(userCredential.user);
      
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
    String? organization,
    String? collegeId,
    List<String>? classesEnrolled,
    String? avatarUrl,
  }) async {
    try {
      await FirebaseService.firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': displayName,
        // Backward compatibility fields
        'displayName': displayName,
        'role': role, // legacy single role field
        'roles': [role],
        'currentRole': role,
        if (organization != null && organization.isNotEmpty) 'organization': organization,
        if (collegeId != null) 'collegeId': collegeId,
        'classesEnrolled': classesEnrolled ?? const [],
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));
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
          'updatedAt': FieldValue.serverTimestamp(),
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

  /// Development-only seeding for a showcase account.
  static const _showcaseUserId = 'DZ1LPLHvDFUwiJBmJwxI72ohyjt1';
  static const _showcaseEmail = 'legendary.squad.0216@gmail.com';

  static Future<void> _maybeSeedSampleAttendance(User? user) async {
    if (user == null) return;
    try {
      if (user.uid != _showcaseUserId && user.email != _showcaseEmail) return;
      final agg = await AttendanceService.fetchUserAggregate(user.uid);
      // If already have at least 50 total sessions across math & science, assume seeded
      final math = agg['MATH101'] as Map<String, dynamic>?;
      final sci = agg['SCI101'] as Map<String, dynamic>?;
      final mathTotal = (math?['totalCount'] as num?)?.toInt() ?? 0;
      final sciTotal = (sci?['totalCount'] as num?)?.toInt() ?? 0;
      if (mathTotal >= 100 && sciTotal >= 100) {
        // Mirror anyway to keep 'attendance' doc updated
        await AttendanceService.mirrorUserAggregate(user.uid, agg);
        return;
      }
      await AttendanceService.seedExactPercentages(
        userId: user.uid,
        classPercentTargets: {
          'MATH101': 69,
          'SCI101': 70,
        },
        totalTarget: 100,
      );
    } catch (e) {
      LogService.warning('Sample attendance seeding skipped: $e');
    }
  }
}

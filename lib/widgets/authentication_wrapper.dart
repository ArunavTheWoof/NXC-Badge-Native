import 'package:flutter/material.dart';
import 'package:test_app1/services/firebase_service.dart';

typedef AuthBuilder = Widget Function(BuildContext context);

class AuthenticationWrapper extends StatelessWidget {
  final AuthBuilder signedInBuilder;
  final AuthBuilder signedOutBuilder;

  const AuthenticationWrapper({
    super.key,
    required this.signedInBuilder,
    required this.signedOutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return signedInBuilder(context);
        }
        return signedOutBuilder(context);
      },
    );
  }
}

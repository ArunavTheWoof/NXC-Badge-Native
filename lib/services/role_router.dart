import 'package:flutter/material.dart';
import 'package:test_app1/Admin/bottom_nav_bar.dart';
import 'package:test_app1/Gatekeeper/bottom_nav_bar_gatekeeper.dart';
import 'package:test_app1/Librarian/librarian_dashboard.dart';
import 'package:test_app1/Organiser/bottom_nav_bar_organiser.dart';
import 'package:test_app1/Student/bottom_nav_bar_student.dart';

class RoleRouter {
  static void goToRoleHome(BuildContext context, String role) {
    final normalized = role.trim().toLowerCase();
    Widget screen;
    switch (normalized) {
      case 'admin':
        screen = const MainScreen();
        break;
      case 'librarian':
        screen = const LibrarianDashboard();
        break;
      case 'gatekeeper':
        screen = const GatekeeperMainScreen();
        break;
      case 'organiser':
      case 'organizer':
        screen = const OrganiserMainScreen();
        break;
      case 'student':
      default:
        screen = const StudentBottomNavbar();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

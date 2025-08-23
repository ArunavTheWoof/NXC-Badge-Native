import 'package:flutter/material.dart';
import 'package:test_app1/Admin/view_students.dart';
import 'package:test_app1/settings.dart'; // New import

// --- Import all the screens you have created ---
// Make sure the file paths are correct based on your project structure.
import "dashboard.dart";
import 'class.dart';

// --- Placeholder Screens for Logs and Profile ---
// You can replace these with your actual screen widgets later.






// --- Main Screen with Bottom Navigation Bar ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to the first tab (Home)

  // List of the screens to be displayed for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(), // Index 0
    ViewStudentsScreen(className: 'All Students'),      // Index 1
    ClassesScreen(),   // Index 2
    SettingsScreen(),   // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            activeIcon: Icon(Icons.class_),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // --- Style to match your design ---
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        backgroundColor: Colors.white,
        elevation: 5.0,
        selectedItemColor: const Color(0xFF3B82F6), // Blue for selected
        unselectedItemColor: const Color(0xFF9E9E9E), // Grey for unselected
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showUnselectedLabels: true,
      ),
    );
  }
}

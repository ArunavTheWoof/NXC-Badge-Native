import 'package:flutter/material.dart';
import 'package:test_app1/Student/student_documents.dart';
import 'package:test_app1/Student/student_dashboard.dart';
import 'package:test_app1/settings.dart';

class StudentBottomNavbar extends StatefulWidget {
  const StudentBottomNavbar({super.key});

  @override
  State<StudentBottomNavbar> createState() => _StudentBottomNavbarState();
}

class _StudentBottomNavbarState extends State<StudentBottomNavbar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    StudentDashboard(),
    StudentDocumentsScreen(),
    SettingsScreen(),
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2 ? Icons.settings : Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String screenName;
  const PlaceholderScreen({super.key, required this.screenName});

  @override
  Widget build(BuildContext context) {
    return Text(
      screenName,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}

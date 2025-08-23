import 'package:flutter/material.dart';
import 'package:test_app1/Librarian/issued_books.dart';
import 'package:test_app1/Librarian/export_data_librarian.dart';
import 'package:test_app1/settings.dart';

class BottomNavBarLibrarian extends StatefulWidget {
  const BottomNavBarLibrarian({super.key});

  @override
  State<BottomNavBarLibrarian> createState() => _BottomNavBarLibrarianState();
}

class _BottomNavBarLibrarianState extends State<BottomNavBarLibrarian> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    IssuedBooksScreen(),
    ExportDataLibrarianScreen(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

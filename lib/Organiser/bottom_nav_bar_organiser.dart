import 'package:flutter/material.dart';
import 'package:test_app1/Organiser/events.dart';
import 'package:test_app1/Organiser/organiser_dashboard.dart';
import 'package:test_app1/settings.dart';

class OrganiserMainScreen extends StatefulWidget {
  const OrganiserMainScreen({super.key});

  @override
  State<OrganiserMainScreen> createState() => _OrganiserMainScreenState();
}

class _OrganiserMainScreenState extends State<OrganiserMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    OrganiserDashboard(),
    EventsScreen(),
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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey.shade400,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 5.0,
      ),
    );
  }
}
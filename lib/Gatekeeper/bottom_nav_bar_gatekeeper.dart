import 'package:flutter/material.dart';
import 'package:test_app1/Gatekeeper/gatekeeper_dashboard.dart';
import 'package:test_app1/Gatekeeper/logs_gatekeeper.dart';
import 'package:test_app1/settings.dart';

class GatekeeperMainScreen extends StatefulWidget {
  const GatekeeperMainScreen({super.key});

  @override
  State<GatekeeperMainScreen> createState() => _GatekeeperMainScreenState();
}

class _GatekeeperMainScreenState extends State<GatekeeperMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    GatekeeperDashboardScreen(),
    LogsGatekeeperScreen(),
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
            icon: Icon(Icons.list_alt_rounded),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF9E7B72),
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

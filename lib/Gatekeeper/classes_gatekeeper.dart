import 'package:flutter/material.dart';

class ClassesGatekeeperScreen extends StatelessWidget {
  final VoidCallback? onAddClass;
  final VoidCallback? onStartAttendance;
  final VoidCallback? onHome;
  final VoidCallback? onLogs;
  final VoidCallback? onProfile;

  const ClassesGatekeeperScreen({
    super.key,
    this.onAddClass,
    this.onStartAttendance,
    this.onHome,
    this.onLogs,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Classes',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Plus icon
                  IconButton(
                    onPressed: onAddClass,
                    icon: const Icon(Icons.add, color: Colors.black, size: 24),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    // Class Card
                    _buildClassCard(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100], // Light gray background
                border: const Border(
                  top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem(Icons.home, 'Home', false, onHome),
                  _buildBottomNavItem(Icons.list, 'Logs', true, onLogs),
                  _buildBottomNavItem(
                    Icons.person,
                    'Profile',
                    false,
                    onProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Classroom Image
          _buildClassroomImage(),

          // Class Details
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mathematics',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Grade 10',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  '10:00 AM - 11:00 AM',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Start Attendance Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStartAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF4A8CD2,
                      ), // Blue background
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC), // Light beige background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Stack(
        children: [
          // Walls (light beige background)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF5F5DC),
          ),

          // Whiteboard
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: const Color(0xFFD2B48C), // Light wooden frame
                  width: 2,
                ),
              ),
            ),
          ),

          // Plant on the left
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 40,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                children: [
                  // Plant pot
                  Positioned(
                    bottom: 0,
                    left: 5,
                    right: 5,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  // Plant leaves
                  Positioned(
                    top: 5,
                    left: 10,
                    right: 10,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Clock on the right
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Stack(
                children: [
                  // Clock hands
                  Center(
                    child: Container(width: 2, height: 8, color: Colors.black),
                  ),
                  Center(
                    child: Container(width: 1, height: 12, color: Colors.black),
                  ),
                  // Clock center dot
                  Center(
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pendant light fixture
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 20,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.grey,
                    size: 12,
                  ),
                ),
              ),
            ),
          ),

          // Desks and chairs (simplified representation)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => _buildDeskChair()),
            ),
          ),

          // Sunlight shadow effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeskChair() {
    return Column(
      children: [
        // Chair
        Container(
          width: 25,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFD2B48C), // Light wood color
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(height: 2),
        // Desk
        Container(
          width: 30,
          height: 15,
          decoration: BoxDecoration(
            color: const Color(0xFFD2B48C), // Light wood color
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isActive
                    ? const Color(0xFF8B4513)
                    : const Color(
                      0xFF87CEEB,
                    ), // Reddish-brown for active, light blue-gray for inactive
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive
                      ? const Color(0xFF8B4513)
                      : const Color(
                        0xFF87CEEB,
                      ), // Reddish-brown for active, light blue-gray for inactive
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

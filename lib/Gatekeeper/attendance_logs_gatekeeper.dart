import 'package:flutter/material.dart';

class AttendanceLogsGatekeeperScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onDateRangeTap;
  final VoidCallback? onClassEventTap;
  final VoidCallback? onExport;
  final VoidCallback? onHome;
  final VoidCallback? onLogs;
  final VoidCallback? onProfile;

  const AttendanceLogsGatekeeperScreen({
    super.key,
    this.onBack,
    this.onDateRangeTap,
    this.onClassEventTap,
    this.onExport,
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
                  // Back arrow
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Attendance Logs',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Empty space for balance
                  const SizedBox(width: 48),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Section
                    _buildDateRangeSection(),
                    const SizedBox(height: 24),

                    // Class/Event Section
                    _buildClassEventSection(),
                    const SizedBox(height: 24),

                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 24),

                    // Student Attendance List
                    _buildStudentAttendanceList(),
                    const SizedBox(height: 32),

                    // Export Button
                    _buildExportButton(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
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

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onDateRangeTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select date range',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Text(
                    '12',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassEventSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class/Event',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onClassEventTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Select class or event',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light gray background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            'Search by student name',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceList() {
    final students = [
      {'name': 'Ethan Harper', 'status': 'Present', 'avatarColor': Colors.teal},
      {
        'name': 'Olivia Bennett',
        'status': 'Absent',
        'avatarColor': Colors.pink,
      },
      {'name': 'Noah Carter', 'status': 'Present', 'avatarColor': Colors.green},
      {
        'name': 'Ava Mitchell',
        'status': 'Present',
        'avatarColor': Colors.purple,
      },
      {'name': 'Liam Foster', 'status': 'Absent', 'avatarColor': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Attendance',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...students.map((student) => _buildStudentAttendanceItem(student)),
      ],
    );
  }

  Widget _buildStudentAttendanceItem(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: student['avatarColor'] as Color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (student['name'] as String)
                    .split(' ')
                    .map((n) => n[0])
                    .join(''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] as String,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student['status'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onExport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4), // Blue background
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Export to CSV',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
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
                    : Colors
                        .grey[600], // Darker gray/brown for active, gray for inactive
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive
                      ? const Color(0xFF8B4513)
                      : Colors
                          .grey[600], // Darker gray/brown for active, gray for inactive
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

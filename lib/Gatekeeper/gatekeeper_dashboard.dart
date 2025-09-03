import 'package:flutter/material.dart';
import 'package:test_app1/Gatekeeper/classes_gatekeeper.dart';

class GatekeeperDashboardScreen extends StatelessWidget {
  final VoidCallback? onSettings;
  final VoidCallback? onViewClasses;
  final VoidCallback? onExportData;
  final VoidCallback? onAddStudent;
  final VoidCallback? onHome;
  final VoidCallback? onLogs;
  final VoidCallback? onProfile;

  const GatekeeperDashboardScreen({
    super.key,
    this.onSettings,
    this.onViewClasses,
    this.onExportData,
    this.onAddStudent,
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
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Settings icon
                  IconButton(
                    onPressed: onSettings,
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 24,
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Metric Cards
                    _buildMetricCards(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 32),

                    // Classes List Section
                    _buildClassesListSection(),
                    const SizedBox(height: 32),

                    // Activity Log Section
                    _buildActivityLogSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: onAddStudent,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Student',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCards() {
    return Column(
      children: [
        // Top row - Total Classes and Overall Attendance %
        Row(
          children: [
            Expanded(child: _buildMetricCard('Total Classes', '12')),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Overall Attendance %', '92%')),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom row - Total Absentees
        Row(
          children: [
            Expanded(child: _buildMetricCard('Total Absentees', '3')),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Empty space for balance
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F0), // Light green/off-white background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionCard(Icons.menu, 'View Classes', () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ClassesGatekeeperScreen()),
          );
        }),
        const SizedBox(height: 12),
        _buildActionCard(Icons.file_upload, 'Export Data', onExportData),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classes List',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Placeholder for classes list content
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Center(
            child: Text(
              'Classes list content will appear here',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Log',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityEntry(
          Icons.add,
          'Class created: Math 101',
          '10:30 AM',
          'Admin',
        ),
        const SizedBox(height: 12),
        _buildActivityEntry(
          Icons.edit,
          'Attendance updated for Science 202',
          '11:45 AM',
          'Admin',
        ),
        const SizedBox(height: 12),
        _buildActivityEntry(
          Icons.notifications,
          'Alert sent to parents of absent students',
          '1:20 PM',
          'Admin',
        ),
      ],
    );
  }

  Widget _buildActivityEntry(
    IconData icon,
    String description,
    String time,
    String user,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF90EE90), // Light green
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user,
                  style: const TextStyle(
                    color: Color(0xFF90EE90), // Light green
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

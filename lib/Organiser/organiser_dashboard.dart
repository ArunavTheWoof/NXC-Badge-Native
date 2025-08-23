import 'package:flutter/material.dart';
import 'package:test_app1/Organiser/create_event_organizer.dart';

// The new "Events" screen widget based on your latest design.
class OrganiserDashboard extends StatelessWidget {
  const OrganiserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('Credits'),
            const SizedBox(height: 12),
            _buildCreditsBalance(),
            const SizedBox(height: 24),
            _buildSectionHeader('Upcoming Events'),
            const SizedBox(height: 12),
            _buildEventItem(
              title: 'Career Fair',
              time: '10:00 AM - 12:00 PM',
            ),
            const SizedBox(height: 16),
            _buildEventItem(
              title: 'Workshop: Resume Building',
              time: '2:00 PM - 4:00 PM',
            ),
            const SizedBox(height: 16),
            _buildEventItem(
              title: 'Networking Event',
              time: '6:00 PM - 8:00 PM',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        label: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF5A99D4),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // A reusable widget for the section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  // Widget for the credits balance and buy button
  Widget _buildCreditsBalance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Credits Balance',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Row(
          children: [
            const Text(
              '100',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement buy credits functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A99D4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Buy Credits',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // A reusable widget for the event list items
  Widget _buildEventItem({required String title, required String time}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_today_outlined, color: Colors.black54),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
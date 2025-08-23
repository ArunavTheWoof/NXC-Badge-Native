import 'package:flutter/material.dart';

// Make sure to import your CreateEventScreen file.
// For example: import 'path/to/create_event_screen.dart';

// Placeholder for the screen to navigate to.
class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: const Center(child: Text("Create Event Screen Placeholder")),
    );
  }
}


// The new "Events" screen widget based on your latest design.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              // This navigates to the CreateEventScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateEventScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 24),
            _buildSectionHeader('Upcoming'),
            const SizedBox(height: 12),
            _buildEventListItem(
              context,
              status: 'Upcoming',
              title: 'School Play Rehearsal',
              details: 'Oct 25, 2024 · 10 participants',
              imageUrl: 'https://placehold.co/80x80/d6b6b3/333333?text=Event',
            ),
            const SizedBox(height: 16),
            _buildEventListItem(
              context,
              status: 'Upcoming',
              title: 'Science Fair',
              details: 'Nov 15, 2024 · 20 participants',
              imageUrl: 'https://placehold.co/80x80/3c4c5a/ffffff?text=Event',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Completed'),
            const SizedBox(height: 12),
            _buildEventListItem(
              context,
              status: 'Completed',
              title: 'Math Olympiad',
              details: 'Sep 10, 2024 · 15 participants',
              imageUrl: 'https://placehold.co/80x80/52c4b9/ffffff?text=Event',
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget for the search bar
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search events',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget for the filter chips
  Widget _buildFilterChips() {
    return Row(
      children: [
        _buildFilterChip('Upcoming', isSelected: true),
        const SizedBox(width: 10),
        _buildFilterChip('Completed', isSelected: false),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ],
      ),
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

  // A reusable widget for the event list items
  Widget _buildEventListItem(
    BuildContext context, {
    required String status,
    required String title,
    required String details,
    required String imageUrl,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

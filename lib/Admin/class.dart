import 'package:flutter/material.dart';
import 'class_details.dart';
import 'view_students.dart';
import 'create_class.dart';
// Assuming you have this screen in your project
// import 'create_new_class_screen.dart';




class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassData {
  final String name;
  final int studentCount;
  _ClassData({required this.name, required this.studentCount});
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Original list of classes
  final List<_ClassData> _allClasses = [
    _ClassData(name: 'Grade 10A', studentCount: 15),
    _ClassData(name: 'Grade 11B', studentCount: 20),
    _ClassData(name: 'Grade 12C', studentCount: 18),
    _ClassData(name: 'Physics 101', studentCount: 25),
    _ClassData(name: 'Chemistry Lab', studentCount: 22),
  ];

  // List to be displayed (will be filtered)
  List<_ClassData> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    // Initially, the filtered list is the full list
    _filteredClasses = _allClasses;
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClasses);
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClasses = _allClasses.where((c) {
        return c.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToCreateClass() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNewClassScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Classes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: _navigateToCreateClass,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search classes',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // "Classes" Title
            const Text(
              'Classes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Classes List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredClasses.length,
                itemBuilder: (context, index) {
                  final classItem = _filteredClasses[index];
                  return _buildClassListItem(
                    classData: classItem,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateClass,
        backgroundColor: const Color(0xFF3B82F6), // Matching blue color
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Widget for each item in the class list
  Widget _buildClassListItem({required _ClassData classData}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Class Name and Student Count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classData.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${classData.studentCount} students',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // Action Buttons
          Row(
            children: [
              _actionButton(
                label: 'View Students',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewStudentsScreen(
                        // Pass the class name, although it's not used in this specific UI
                        className: classData.name,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'View Class',
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsScreen(
                        // Pass the class name to the details screen
                        className: classData.name,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (String result) {
                  if (result == 'remove_class') {
                    setState(() {
                      _allClasses.remove(classData);
                      _filterClasses(); // Re-filter to update the displayed list
                    });
                  }
                  // TODO: Implement other options if needed
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'export_attendance',
                    child: Text('Export attendance'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'assign_teacher',
                    child: Text('Assign teacher'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'remove_class',
                    child: Text('Remove class'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable widget for the small action buttons
  Widget _actionButton({required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

import 'package:flutter/material.dart';

// Data model for a subject
class Subject {
  final String name;
  String? teacherName; // Nullable for unassigned teachers

  Subject({required this.name, this.teacherName});
}

class ClassDetailsScreen extends StatefulWidget {
  final String className;

  const ClassDetailsScreen({super.key, required this.className});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for subjects
  final List<Subject> _allSubjects = [
    Subject(name: 'Mathematics', teacherName: 'Mr. Arjun Patel'),
    Subject(name: 'Science', teacherName: 'Ms. Priya Sharma'),
    Subject(name: 'History'), // No teacher assigned
    Subject(name: 'English', teacherName: 'Mr. Rohan Verma'),
    Subject(name: 'Geography', teacherName: 'Mrs. Anjali Mehta'),
  ];

  List<Subject> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = _allSubjects;
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSubjects);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubjects = _allSubjects.where((subject) {
        return subject.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _deleteSubject(Subject subjectToDelete) {
    setState(() {
      _allSubjects.remove(subjectToDelete);
      _filterSubjects(); // Re-apply filter to update the displayed list
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Class Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Class Title
            Text(
              widget.className,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Search Box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search subjects',
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

            // Subjects List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _filteredSubjects[index];
                  return _buildSubjectListItem(subject);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for each subject in the list
  Widget _buildSubjectListItem(Subject subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Book Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.black54),
          ),
          const SizedBox(width: 16),

          // Subject and Teacher Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject.teacherName ?? 'No teacher assigned',
                  style: TextStyle(
                    fontSize: 14,
                    color: subject.teacherName != null
                        ? Colors.grey.shade600
                        : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),

          // Conditional Action (Assign Button or Delete Icon)
          if (subject.teacherName == null)
            TextButton(
              onPressed: () {
                // TODO: Navigate to an "Assign Teacher" screen
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Assign', style: TextStyle(fontWeight: FontWeight.w500)),
            )
          else
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
              onPressed: () => _deleteSubject(subject),
            ),
        ],
      ),
    );
  }
}

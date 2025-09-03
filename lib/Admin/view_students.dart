import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// A simple data model for a student
class Student {
  final String name;
  final String email;
  final String imageUrl; // URL for the avatar image

  const Student({required this.name, required this.email, required this.imageUrl});
}

class ViewStudentsScreen extends StatelessWidget {
  final String className;

  const ViewStudentsScreen({super.key, required this.className});

  // Dummy data for the student list
  final List<Student> students = const [
    Student(name: 'Sophia Clark', email: 'sophia.clark@example.com', imageUrl: 'https://i.pravatar.cc/150?img=1'),
    Student(name: 'Liam Evans', email: 'liam.evans@example.com', imageUrl: 'https://i.pravatar.cc/150?img=2'),
    Student(name: 'Olivia Green', email: 'olivia.green@example.com', imageUrl: 'https://i.pravatar.cc/150?img=3'),
    Student(name: 'Noah Harris', email: 'noah.harris@example.com', imageUrl: 'https://i.pravatar.cc/150?img=4'),
    Student(name: 'Ava Jackson', email: 'ava.jackson@example.com', imageUrl: 'https://i.pravatar.cc/150?img=5'),
    Student(name: 'Ethan King', email: 'ethan.king@example.com', imageUrl: 'https://i.pravatar.cc/150?img=6'),
    Student(name: 'Isabella Lee', email: 'isabella.lee@example.com', imageUrl: 'https://i.pravatar.cc/150?img=7'),
    Student(name: 'Mason Lopez', email: 'mason.lopez@example.com', imageUrl: 'https://i.pravatar.cc/150?img=8'),
    Student(name: 'Mia Martinez', email: 'mia.martinez@example.com', imageUrl: 'https://i.pravatar.cc/150?img=9'),
    Student(name: 'Logan Nelson', email: 'logan.nelson@example.com', imageUrl: 'https://i.pravatar.cc/150?img=10'),
  ];

  void _showToast() {
    Fluttertoast.showToast(
      msg: "File started downloading!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
          'Student List',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                // Student Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(student.imageUrl),
                ),
                const SizedBox(width: 16),
                // Student Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Download Button
                IconButton(
                  icon: Icon(Icons.download_outlined, color: Colors.grey.shade700),
                  onPressed: _showToast,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

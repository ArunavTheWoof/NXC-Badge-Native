import 'package:flutter/material.dart';
import 'package:test_app1/Student/document_viewer.dart';

class StudentDocumentsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onViewHallTicket;
  final VoidCallback? onViewEventPass;
  final VoidCallback? onHome;
  final VoidCallback? onWallet;
  final VoidCallback? onSettings;

  const StudentDocumentsScreen({
    super.key,
    this.onBack,
    this.onSearch,
    this.onViewHallTicket,
    this.onViewEventPass,
    this.onHome,
    this.onWallet,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey[600]),
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                  ),
                  onTap: onSearch,
                ),
              ),

              // Hall Tickets Section
              const Text(
                'Hall Tickets',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 15),
              _buildDocumentCard(
                context,
                title: 'Semester 1 Exam',
                issueDate: 'Issued on 12/01/2024',
                imagePath: 'lib/assets/book1_lib.png', // Using existing asset
                onView: onViewHallTicket,
              ),
              const SizedBox(height: 30),

              // Event Passes Section
              const Text(
                'Event Passes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 15),
              _buildDocumentCard(
                context,
                title: 'Tech Fest 2024',
                issueDate: 'Issued on 03/15/2024',
                imagePath:
                    'lib/assets/techfest2024_student.png', // Using existing asset
                onView: onViewEventPass,
              ),
              const SizedBox(
                height: 20,
              ), // Space before bottom nav if content is short
            ],
          ),
        ),
      ),
      
    );
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required String title,
    required String issueDate,
    required String imagePath,
    VoidCallback? onView,
  }) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  issueDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DocumentViewerScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    elevation: 0,
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Document illustration
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

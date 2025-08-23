import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({
    super.key,
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
                  // Back button
                  const BackButton(),
                  const Expanded(
                    child: Text(
                      'Document Viewer',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Search button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement search functionality
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 24,
                    ),
                    // TODO: Replace with your own image icon
                    // icon: Image.asset('lib/assets/search_icon.png'),
                  ),
                  // View button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement view functionality
                    },
                    icon: const Icon(
                      Icons.visibility,
                      color: Colors.black,
                      size: 24,
                    ),
                    // TODO: Replace with your own image icon
                    // icon: Image.asset('lib/assets/view_icon.png'),
                  ),
                ],
              ),
            ),

            // Document display area
            Expanded(
              child: Container(
                color: const Color(
                  0xFFD2691E,
                ), // Orange-brown/terracotta background
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PDF label
                          const Text(
                            'PDF',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Simulated document content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header section
                                Container(
                                  width: double.infinity,
                                  height: 2,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 15),

                                // Title
                                Container(
                                  width: 200,
                                  height: 8,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 20),

                                // Form fields simulation
                                _buildFormField('Name:', 'John Doe'),
                                _buildFormField('Student ID:', 'STU2024001'),
                                _buildFormField('Course:', 'Computer Science'),
                                _buildFormField('Semester:', '1st Semester'),
                                _buildFormField(
                                  'Exam Date:',
                                  'December 15, 2024',
                                ),
                                _buildFormField('Venue:', 'Hall A, Block 2'),

                                const SizedBox(height: 20),

                                // Additional content lines
                                _buildContentLine(context, 0.8),
                                _buildContentLine(context, 0.6),
                                _buildContentLine(context, 0.9),
                                _buildContentLine(context, 0.7),
                                _buildContentLine(context, 0.5),

                                const SizedBox(height: 20),

                                // Footer section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 6,
                                      color: Colors.black,
                                    ),
                                    Container(
                                      width: 80,
                                      height: 6,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 8, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildContentLine(BuildContext context, double widthFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor * 0.6,
        height: 6,
        color: Colors.black,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AssignRolesScreen extends StatelessWidget {
  const AssignRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigates back to the previous screen (Dashboard)
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Assign Roles',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for user',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 24),

            // Role Field
            _buildLabeledTextField(label: 'Role', hint: 'Select a role'),
            const SizedBox(height: 24),

            // Subject Field
            _buildLabeledTextField(label: 'Subject', hint: 'Select a subject'),
            const SizedBox(height: 24),

            // Class Field
            _buildLabeledTextField(label: 'Class', hint: 'Select a class'),
            const SizedBox(height: 40),

            // Assign Role Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement assign role logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Exact blue from image
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Assign Role',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for a label and a text field
  Widget _buildLabeledTextField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        // This can be replaced with a DropdownButtonFormField for a real app
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            // Example of adding a dropdown icon if you were to use a DropdownButton
            // suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

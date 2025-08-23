import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onChangePicture;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.onBack,
    this.onChangePicture,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values
    _nameController.text = 'Ethan Carter';
    _emailController.text = 'ethan.carter@email.com';
    _studentIdController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

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
                  const BackButton(),
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
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
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    _buildPersonalInformationSection(),
                    const SizedBox(height: 40),

                    // Logout Button
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        // Large circular avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC), // Light beige background
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.brown, size: 80),
        ),
        const SizedBox(height: 16),

        // Name
        const Text(
          'Ethan Carter',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Email
        Text(
          'ethan.carter@email.com',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 20),

        // Change Picture button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onChangePicture,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5F5F5), // Light gray background
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              elevation: 0,
            ),
            child: const Text(
              'Change Picture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Name field
        _buildInputField('Name', _nameController),
        const SizedBox(height: 16),

        // Email field
        _buildInputField('Email', _emailController),
        const SizedBox(height: 16),

        // Student ID field
        _buildInputField('Student ID', _studentIdController),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5), // Light gray background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5), // Light gray background
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          elevation: 0,
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  
}

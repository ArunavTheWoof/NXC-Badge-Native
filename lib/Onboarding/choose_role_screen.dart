import 'package:flutter/material.dart';

class ChooseRoleScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final Function(String)? onRoleSelected;
  final String? selectedRole;

  const ChooseRoleScreen({
    super.key,
    this.onBack,
    this.onContinue,
    this.onRoleSelected,
    this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Back arrow
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Select your role',
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

            // Role selection grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    // Student
                    _buildRoleCard(
                      'Student',
                      'lib/assets/student_role.png',
                      const Color(0xFFF5F5DC), // Light beige
                      isSelected: selectedRole == 'Student',
                    ),
                    // Admin
                    _buildRoleCard(
                      'Admin',
                      'lib/assets/admin_role.png',
                      const Color(0xFFE8F5E8), // Light sage green
                      isSelected: selectedRole == 'Admin',
                    ),
                    // Organizer
                    _buildRoleCard(
                      'Organizer',
                      'lib/assets/organizer_role.png',
                      const Color(0xFFF5F5DC), // Light beige
                      isSelected: selectedRole == 'Organizer',
                    ),
                    // Librarian
                    _buildRoleCard(
                      'Librarian',
                      'lib/assets/librarian_role.png',
                      const Color(0xFFF5F5DC), // Light beige
                      isSelected: selectedRole == 'Librarian',
                    ),
                    // Gatekeeper
                    _buildRoleCard(
                      'Gatekeeper',
                      'lib/assets/gatekeeper_role.png',
                      const Color(0xFFE8F0E8), // Dark green/brown
                      isSelected: selectedRole == 'Gatekeeper',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Back button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5), // Light gray
                          foregroundColor: const Color(0xFF666666), // Dark gray
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Continue button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedRole != null ? onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3), // Solid blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(String roleName, String assetPath, Color backgroundColor, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => onRoleSelected?.call(roleName),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF2196F3), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Role name
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  roleName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

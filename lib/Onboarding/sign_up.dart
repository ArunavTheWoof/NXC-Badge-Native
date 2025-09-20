import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:test_app1/Onboarding/choose_role_screen.dart';
import 'package:test_app1/services/auth_service.dart';
import 'package:test_app1/services/role_router.dart';
import 'package:test_app1/services/firebase_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onSignIn;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onPrivacyPolicy;
  final Function(String, String, String, String, String)? onSignUp;

  const SignUpScreen({
    super.key,
    this.onClose,
    this.onSignIn,
    this.onTermsOfService,
    this.onPrivacyPolicy,
    this.onSignUp,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!(_formKey.currentState!.validate() && _agreeToTerms)) return;

    // If external handler is supplied, preserve it
    if (widget.onSignUp != null) {
      widget.onSignUp!.call(
        _nameController.text,
        _organizationController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      return;
    }

    // Embedded flow: ask for role, then create account and route
    Future<void> proceed(String role) async {
      try {
        final cred = await AuthService.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          role: role.trim().toLowerCase(),
        );

        // Add optional organization to user doc if provided
        if (cred?.user != null && _organizationController.text.trim().isNotEmpty) {
          await FirebaseService.firestore
              .collection('users')
              .doc(cred!.user!.uid)
              .update({'organization': _organizationController.text.trim()});
        }

        if (!mounted) return;
        RoleRouter.goToRoleHome(context, role);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e is Exception ? e.toString() : e}')),
        );
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChooseRoleScreen(
          onBack: () => Navigator.of(context).pop(),
          onRoleSelected: (role) async {
            // Immediately proceed once a role is tapped
            Navigator.of(context).pop();
            await proceed(role);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Close button
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the close button
                  ],
                ),
                const SizedBox(height: 32),

                // Input fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        _buildTextField(
                          controller: _nameController,
                          placeholder: 'Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Organization/College field
                        _buildTextField(
                          controller: _organizationController,
                          placeholder: 'Organization/College',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your organization/college';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          placeholder: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          placeholder: 'Password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password field
                        _buildTextField(
                          controller: _confirmPasswordController,
                          placeholder: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Terms and Privacy checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF2196F3),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: const TextStyle(
                                          color: Color(0xFF2196F3),
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = widget.onTermsOfService,
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(
                                          color: Color(0xFF2196F3),
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = widget.onPrivacyPolicy,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _agreeToTerms ? _handleSignUp : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer link
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer:
                                TapGestureRecognizer()..onTap = widget.onSignIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // Light gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

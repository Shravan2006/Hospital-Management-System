// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

final supabase = Supabase.instance.client;

class SignupScreen extends StatefulWidget {
  final String userType; // 'patient', 'doctor', 'admin'

  const SignupScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Patient specific
  final _dobController = TextEditingController();
  String? _selectedGender;
  final _bloodGroupController = TextEditingController();

  // Doctor specific
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  String? _selectedDepartment;

  // Admin specific
  final _usernameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Color _getUserTypeColor() {
    switch (widget.userType) {
      case 'patient':
        return Colors.blue;
      case 'doctor':
        return Colors.pink;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getUserTypeIcon() {
    switch (widget.userType) {
      case 'patient':
        return Icons.person;
      case 'doctor':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('🔵 Step 1: Creating auth user');

      // 1. Create authentication user
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (authResponse.user != null) {
        final userId = authResponse.user!.id;
        print('🔵 Step 2: Auth user created with ID: $userId');

        // 2. Call database function to create profile (bypasses RLS)
        try {
          if (widget.userType == 'patient') {
            print('🔵 Step 3: Creating patient profile via function');

            await supabase.rpc('create_patient_profile', params: {
              'user_id': userId,
              'user_email': _emailController.text.trim(),
              'user_name': _nameController.text.trim(),
              'user_phone': _phoneController.text.trim(),
              'user_dob': _dobController.text.isEmpty ? null : _dobController.text,
              'user_gender': _selectedGender,
              'user_blood_group': _bloodGroupController.text.trim().isEmpty
                  ? null
                  : _bloodGroupController.text.trim(),
            });

          } else if (widget.userType == 'doctor') {
            print('🔵 Step 3: Creating doctor profile via function');

            await supabase.rpc('create_doctor_profile', params: {
              'user_id': userId,
              'user_email': _emailController.text.trim(),
              'user_name': _nameController.text.trim(),
              'user_phone': _phoneController.text.trim(),
              'user_specialization': _specializationController.text.trim(),
              'user_license': _licenseController.text.trim(),
              'user_department': _selectedDepartment,
            });

          } else if (widget.userType == 'admin') {
            print('🔵 Step 3: Creating admin profile via function');

            await supabase.rpc('create_admin_profile', params: {
              'user_id': userId,
              'user_email': _emailController.text.trim(),
              'user_username': _usernameController.text.trim(),
            });
          }

          print('✅ Step 4: Profile created successfully!');

          // Sign out after signup (user needs to login)
          await supabase.auth.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully! Please login.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigate back to login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(userType: widget.userType),
              ),
            );
          }
        } catch (profileError) {
          print('❌ PROFILE CREATION ERROR: $profileError');

          // If profile creation failed, delete the auth user to keep things clean
          try {
            await supabase.auth.admin.deleteUser(userId);
          } catch (e) {
            print('Could not clean up auth user: $e');
          }

          _showError('Profile creation failed: ${profileError.toString()}\n\nPlease check that database functions exist.');
        }
      }
    } on AuthException catch (e) {
      print('❌ AUTH ERROR: ${e.message}');
      _showError(e.message);
    } catch (e) {
      print('❌ GENERAL ERROR: $e');
      _showError('Signup failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getUserTypeColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getUserTypeIcon(),
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Title
                Text(
                  'CREATE ${widget.userType.toUpperCase()} ACCOUNT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Fill in the details to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),

                // Common Fields for All
                if (widget.userType == 'admin') ...[
                  // Username for Admin
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Choose a username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ] else ...[
                  // Full Name for Patient and Doctor
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Phone (not for admin)
                if (widget.userType != 'admin') ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],

                // Patient Specific Fields
                if (widget.userType == 'patient') ...[
                  // Date of Birth
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'Select your date of birth',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 16),
                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedGender = value);
                    },
                  ),
                  SizedBox(height: 16),
                  // Blood Group
                  TextFormField(
                    controller: _bloodGroupController,
                    decoration: InputDecoration(
                      labelText: 'Blood Group (Optional)',
                      hintText: 'e.g., O+, A-, B+',
                      prefixIcon: Icon(Icons.bloodtype_outlined),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Doctor Specific Fields
                if (widget.userType == 'doctor') ...[
                  // Department
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    items: [
                      'Cardiology',
                      'Radiology',
                      'Pathology',
                      'Ophthalmology',
                      'General Medicine',
                      'Orthopedics',
                      'Neurology'
                    ]
                        .map((dept) => DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedDepartment = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a department';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Specialization
                  TextFormField(
                    controller: _specializationController,
                    decoration: InputDecoration(
                      labelText: 'Specialization',
                      hintText: 'e.g., Interventional Cardiologist',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your specialization';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // License Number
                  TextFormField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: 'License Number',
                      hintText: 'Medical license number',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your license number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
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
                SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(
                                () => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
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
                SizedBox(height: 32),

                // Sign Up Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      disabledBackgroundColor: color.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(userType: widget.userType),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final bool isFirstTime;

  const ProfileScreen({super.key, this.isFirstTime = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _dobController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _mothersNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _currentMedicinesController;
  late TextEditingController _allergiesController;
  late TextEditingController _pastInjuriesController;
  late TextEditingController _pastSurgeriesController;
  late TextEditingController _additionalNotesController;

  String? _gender;
  String? _bloodGroup;
  bool _isTakingMedicines = false;
  List<String> _selectedConditions = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _userId;

  final List<String> _medicalConditions = [
    'Diabetes',
    'Hypertension (High BP)',
    'Asthma',
    'Heart Disease',
    'Thyroid',
    'Arthritis',
    'Kidney Disease',
    'Liver Disease',
    'Cancer',
    'None'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _contactController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _dobController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _mothersNameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
    _currentMedicinesController = TextEditingController();
    _allergiesController = TextEditingController();
    _pastInjuriesController = TextEditingController();
    _pastSurgeriesController = TextEditingController();
    _additionalNotesController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      _userId = user.id;
      _emailController.text = user.email ?? '';

      // Fetch patient data from patient_data table
      final response = await Supabase.instance.client
          .from('patient_data')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        _populateFields(response);
      } else {
        // New user - get name from auth metadata
        final metadata = user.userMetadata ?? {};
        _nameController.text = metadata['full_name'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    _nameController.text = data['full_name'] ?? '';
    _contactController.text = data['contact_no'] ?? '';
    _emergencyContactController.text = data['emergency_contact_no'] ?? '';
    _dobController.text = data['date_of_birth'] ?? '';
    _ageController.text = data['age']?.toString() ?? '';
    _heightController.text = data['height_cm']?.toString() ?? '';
    _weightController.text = data['weight_kg']?.toString() ?? '';
    _mothersNameController.text = data['mothers_name'] ?? '';
    _addressController.text = data['address'] ?? '';
    _cityController.text = data['city'] ?? '';
    _stateController.text = data['state'] ?? '';
    _pincodeController.text = data['pincode'] ?? '';
    _currentMedicinesController.text = data['current_medicines'] ?? '';
    _allergiesController.text = data['allergies'] ?? '';
    _pastInjuriesController.text = data['past_injuries'] ?? '';
    _pastSurgeriesController.text = data['past_surgeries'] ?? '';
    _additionalNotesController.text = data['additional_notes'] ?? '';

    _gender = data['gender'];
    _bloodGroup = data['blood_group'];
    _isTakingMedicines = data['is_taking_medicines'] ?? false;

    if (data['medical_conditions'] != null) {
      _selectedConditions = List<String>.from(data['medical_conditions']);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileData = {
        'user_id': _userId,
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact_no': _contactController.text.trim(),
        'emergency_contact_no': _emergencyContactController.text.trim(),
        'date_of_birth': _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        'age': _ageController.text.trim().isNotEmpty ? int.parse(_ageController.text.trim()) : null,
        'gender': _gender,
        'blood_group': _bloodGroup,
        'height_cm': _heightController.text.trim().isNotEmpty ? double.parse(_heightController.text.trim()) : null,
        'weight_kg': _weightController.text.trim().isNotEmpty ? double.parse(_weightController.text.trim()) : null,
        'mothers_name': _mothersNameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'is_taking_medicines': _isTakingMedicines,
        'current_medicines': _currentMedicinesController.text.trim(),
        'medical_conditions': _selectedConditions.isEmpty ? null : _selectedConditions,
        'allergies': _allergiesController.text.trim(),
        'past_injuries': _pastInjuriesController.text.trim(),
        'past_surgeries': _pastSurgeriesController.text.trim(),
        'additional_notes': _additionalNotesController.text.trim(),
        'profile_completed': true,
      };

      await Supabase.instance.client
          .from('patient_data')
          .upsert(profileData);

      // Update auth metadata with name
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameController.text.trim()}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.isFirstTime) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _ageController.text = (DateTime.now().year - picked.year).toString();
      });
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.isFirstTime ? 'Complete Your Profile' : 'My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.isFirstTime)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.local_hospital, size: 48, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Welcome to Nanavati Hospital',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please complete your profile for better healthcare services',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Basic Information
            _buildSection('Basic Information', [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name *',
                icon: Icons.person,
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _contactController,
                label: 'Contact Number *',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              _buildTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact Number',
                icon: Icons.emergency,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              ),
            ]),

            // Personal Details
            _buildSection('Personal Details', [
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: const Icon(Icons.wc, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                decoration: InputDecoration(
                  labelText: 'Blood Group *',
                  prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (val) => setState(() => _bloodGroup = val),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _mothersNameController,
                label: "Mother's Name",
                icon: Icons.family_restroom,
              ),
            ]),

            // Physical Measurements
            _buildSection('Physical Measurements', [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ]),

            // Address
            _buildSection('Address', [
              _buildTextField(
                controller: _addressController,
                label: 'Full Address',
                icon: Icons.home,
                maxLines: 2,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      icon: Icons.map,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.pin_drop,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              ),
            ]),

            // Medical Information
            _buildSection('Medical Information', [
              const Text(
                'Medical Conditions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _medicalConditions.map((condition) {
                  final isSelected = _selectedConditions.contains(condition);
                  return FilterChip(
                    label: Text(condition),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (condition == 'None') {
                          _selectedConditions.clear();
                          if (selected) _selectedConditions.add('None');
                        } else {
                          _selectedConditions.remove('None');
                          if (selected) {
                            _selectedConditions.add(condition);
                          } else {
                            _selectedConditions.remove(condition);
                          }
                        }
                      });
                    },
                    selectedColor: const Color(0xFF2563EB).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2563EB),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Currently Taking Medicines?'),
                value: _isTakingMedicines,
                onChanged: (val) => setState(() => _isTakingMedicines = val),
                activeColor: const Color(0xFF2563EB),
              ),
              if (_isTakingMedicines)
                _buildTextField(
                  controller: _currentMedicinesController,
                  label: 'Current Medicines (comma separated)',
                  icon: Icons.medication,
                  maxLines: 3,
                ),
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                icon: Icons.warning_amber,
                maxLines: 2,
              ),
            ]),

            // Medical History
            _buildSection('Medical History', [
              _buildTextField(
                controller: _pastInjuriesController,
                label: 'Past Injuries',
                icon: Icons.healing,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _pastSurgeriesController,
                label: 'Past Surgeries',
                icon: Icons.local_hospital,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _additionalNotesController,
                label: 'Additional Medical Notes',
                icon: Icons.notes,
                maxLines: 4,
              ),
            ]),

            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                widget.isFirstTime ? 'Complete Profile' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            if (!widget.isFirstTime)
              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await Supabase.instance.client.auth.signOut();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _emergencyContactController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _mothersNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _currentMedicinesController.dispose();
    _allergiesController.dispose();
    _pastInjuriesController.dispose();
    _pastSurgeriesController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }
}
// lib/screens/patient_home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hospital_app_new/patient/package_detail_screen.dart';
import 'package:hospital_app_new/hospital/appointments_screen.dart';
import 'package:hospital_app_new/patient/chat_screen.dart';
import 'package:hospital_app_new/patient/profile_screen.dart';

import 'package:hospital_app_new/patient/screens/categories/blood_tests_screen.dart';
import 'package:hospital_app_new/patient/screens/categories/cardiology_screen.dart';
import 'package:hospital_app_new/patient/screens/categories/radiology_screen.dart';
import 'package:hospital_app_new/patient/screens/categories/health_packages_screen.dart';
import 'package:hospital_app_new/patient/screens/categories/consultation_screen.dart';
import 'package:hospital_app_new/patient/screens/categories/eye_checkup_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final String userName;
  const PatientHomeScreen({super.key, required this.userName});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<String> _recentSearches = [];
  String _displayName = '';
  bool _isCheckingProfile = true;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.bloodtype, 'label': 'Blood Tests', 'color': Colors.red, 'offer': 25},
    {'icon': Icons.monitor_heart, 'label': 'Cardiology', 'color': Colors.purple, 'offer': 20},
    {'icon': Icons.scanner, 'label': 'Radiology', 'color': Colors.blue, 'offer': 15},
    {'icon': Icons.medical_services, 'label': 'Health Packages', 'color': Colors.green, 'offer': 30},
    {'icon': Icons.local_hospital, 'label': 'Consultation', 'color': Colors.orange, 'offer': 0},
    {'icon': Icons.remove_red_eye, 'label': 'Eye Checkup', 'color': Colors.teal, 'offer': 18},
  ];

  final List<Map<String, dynamic>> recommendedPackages = [
    {
      'id': 1,
      'name': 'Full Body Health Checkup',
      'price': '₹4,999',
      'original': '₹8,500',
      'tests': 72,
      'tests_list': ['CBC', 'LFT', 'KFT', 'Lipid Profile', 'Thyroid', 'Vitamin D', 'HbA1c', '...'],
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)]
    },
    {
      'id': 2,
      'name': 'Diabetes Screening',
      'price': '₹1,299',
      'original': '₹2,200',
      'tests': 18,
      'tests_list': ['Fasting Glucose', 'HbA1c', 'Insulin', 'Urine Microalbumin', '...'],
      'gradient': [Color(0xFFF093FB), Color(0xFFF5576C)]
    },
    {
      'id': 3,
      'name': 'Heart Check Premium',
      'price': '₹6,999',
      'original': '₹12,000',
      'tests': 45,
      'tests_list': ['ECG', '2D Echo', 'TMT', 'Lipid Profile', 'CRP', '...'],
      'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)]
    },
  ];

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _loadRecentSearches();
    _checkProfileStatus();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) _loadRecentSearches();
    });
  }

  Future<void> _checkProfileStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Check if profile exists and is completed
      final response = await Supabase.instance.client
          .from('patient_data')
          .select('profile_completed, full_name')
          .eq('user_id', user.id)
          .maybeSingle();

      setState(() => _isCheckingProfile = false);

      if (response == null || response['profile_completed'] != true) {
        // Show first-time profile setup dialog
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          _showProfileSetupDialog();
        }
      } else {
        // Update display name from database
        setState(() {
          _displayName = response['full_name'] ?? widget.userName;
        });
      }
    } catch (e) {
      setState(() => _isCheckingProfile = false);
    }
  }

  Future<void> _showProfileSetupDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital, color: Color(0xFF2563EB), size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Welcome!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Nanavati Hospital',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 12),
            Text(
              'To provide you with the best healthcare services, we need to know more about you.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please complete your profile for further procedures',
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Setup Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await _navigateToProfile(isFirstTime: true);
    }
  }

  Future<void> _navigateToProfile({bool isFirstTime = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(isFirstTime: isFirstTime),
      ),
    );

    // Refresh name if profile was updated
    if (result == true) {
      _refreshUserName();
    }
  }

  Future<void> _refreshUserName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('patient_data')
          .select('full_name')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && response['full_name'] != null) {
        setState(() {
          _displayName = response['full_name'];
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> updated = [query, ..._recentSearches.where((e) => e != query)];
    if (updated.length > 5) updated.removeLast();
    await prefs.setStringList('recent_searches', updated);
    setState(() => _recentSearches = updated);
  }

  void _navigateToCategory(String label) {
    Widget screen;
    switch (label) {
      case 'Blood Tests':
        screen = const BloodTestsScreen();
        break;
      case 'Cardiology':
        screen = const CardiologyScreen();
        break;
      case 'Radiology':
        screen = const RadiologyScreen();
        break;
      case 'Health Packages':
        screen = const HealthPackagesScreen();
        break;
      case 'Consultation':
        screen = const ConsultationScreen();
        break;
      case 'Eye Checkup':
        screen = const EyeCheckupScreen();
        break;
      default:
        screen = const Scaffold(body: Center(child: Text("Coming Soon")));
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => screen,
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _handleNavTap(int index) {
    if (index == 0) return;

    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentsScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
        break;
      case 3:
        _navigateToProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $_displayName!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[900]),
            ),
            Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          if (!_isCheckingProfile)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF2563EB)),
              ),
              onPressed: () => _navigateToProfile(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _saveRecentSearch(value.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Searching: $value")),
                    );
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Search tests, packages, doctors...",
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2563EB)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            // Recent Searches
            if (_searchFocus.hasFocus && _recentSearches.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Searches",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._recentSearches.map((s) => ListTile(
                      title: Text(s),
                      leading: const Icon(Icons.history),
                      onTap: () {
                        _searchController.text = s;
                        _saveRecentSearch(s);
                      },
                    )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),

            // Quick Services
            const Text(
              "Quick Services",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.98,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final int offer = cat['offer'] ?? 0;

                return GestureDetector(
                  onTap: () => _navigateToCategory(cat['label']),
                  child: Hero(
                    tag: 'category_${cat['label']}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (cat['color'] as Color).withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: (cat['color'] as Color).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(cat['icon'], size: 32, color: cat['color']),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    cat['label'],
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (offer > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "$offer% OFF",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Recommended Packages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recommended for You",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedPackages.length,
              itemBuilder: (context, index) {
                final pkg = recommendedPackages[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: pkg['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${pkg['tests']} Tests Included",
                                style: TextStyle(color: Colors.white.withOpacity(0.9)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    pkg['price'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    pkg['original'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PackageDetailScreen(package: pkg),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: pkg['gradient'][0],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            "Book Now",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
}
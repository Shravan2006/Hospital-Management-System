// lib/screens/patient/health_packages_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_appointment_screen.dart';

final supabase = Supabase.instance.client;

class HealthPackagesScreen extends StatefulWidget {
  final String patientId;

  const HealthPackagesScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<HealthPackagesScreen> createState() => _HealthPackagesScreenState();
}

class _HealthPackagesScreenState extends State<HealthPackagesScreen> {
  List<dynamic> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      // For now, we'll create sample packages
      // In future, load from health_packages table
      setState(() {
        packages = [
          {
            'id': 'package1',
            'name': 'Basic Health Checkup',
            'description': 'Essential health screening for overall wellness',
            'price': 1999.0,
            'tests': [
              'Complete Blood Count (CBC)',
              'Blood Sugar (Fasting)',
              'Lipid Profile',
              'Liver Function Test',
              'Kidney Function Test',
              'Thyroid Test',
              'Urine Analysis'
            ],
            'duration': 45,
            'color': 0xFFF093FB,
          },
          {
            'id': 'package2',
            'name': 'Full Body Checkup',
            'description': 'Comprehensive health assessment',
            'price': 3999.0,
            'tests': [
              'All Basic Health Tests',
              'ECG (Electrocardiogram)',
              'Chest X-Ray',
              'Vision Test',
              'Dental Checkup',
              'Ultrasound Abdomen',
              'BMI Analysis',
              'Blood Pressure Monitoring'
            ],
            'duration': 90,
            'color': 0xFF4FACFE,
          },
          {
            'id': 'package3',
            'name': 'Premium Health Package',
            'description': 'Complete health screening with advanced tests',
            'price': 7999.0,
            'tests': [
              'All Full Body Tests',
              'CT Scan',
              'Advanced Cardiac Profile',
              'Cancer Markers',
              'Vitamin Profile',
              'Bone Density Test',
              'Stress Test',
              'Pulmonary Function Test'
            ],
            'duration': 120,
            'color': 0xFFFA709A,
          },
          {
            'id': 'package4',
            'name': 'Senior Citizen Package',
            'description': 'Specially designed for 60+ age group',
            'price': 5999.0,
            'tests': [
              'All Basic Health Tests',
              'ECG',
              'Bone Density Test',
              'Arthritis Panel',
              'Cardiac Risk Assessment',
              'Diabetes Screening',
              'Eye Examination',
              'Hearing Test'
            ],
            'duration': 75,
            'color': 0xFF11998E,
          },
          {
            'id': 'package5',
            'name': 'Women\'s Health Package',
            'description': 'Comprehensive checkup for women',
            'price': 4999.0,
            'tests': [
              'All Basic Health Tests',
              'Hormone Panel',
              'Thyroid Function',
              'Iron & Vitamin D',
              'Breast Examination',
              'Pelvic Ultrasound',
              'Pap Smear',
              'Bone Density'
            ],
            'duration': 80,
            'color': 0xFFEE9CA7,
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading packages: $e');
      setState(() => isLoading = false);
    }
  }

  Future<List<String>> _getPackageTestIds(String packageId) async {
    try {
      print('🔵 Loading test IDs for package: $packageId');

      final data = await supabase
          .from('health_package_tests')
          .select('test_id')
          .eq('package_id', packageId);

      final testIds = data.map((item) => item['test_id'] as String).toList();
      print('✅ Found ${testIds.length} tests for package');

      return testIds;
    } catch (e) {
      print('❌ Error loading package tests: $e');
      return [];
    }
  }

  void _showPackageDetails(Map<String, dynamic> package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Package name
                  Text(
                    package['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    package['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Price and duration
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.monetization_on,
                        '₹${package['price']}',
                        Colors.green,
                      ),
                      SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.access_time,
                        '~${package['duration']} mins',
                        Colors.blue,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Tests included
                  Text(
                    'Tests Included',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  ...List.generate(
                    (package['tests'] as List).length,
                        (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              package['tests'][index],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        // Load real test IDs from database
                        final testIds = await _getPackageTestIds(package['id']);

                        if (testIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No tests found for this package'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppointmentScreen(
                              testIds: testIds, // ← Now using real test IDs!
                              patientId: widget.patientId,
                              isPackage: true,
                              packageId: package['id'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(package['color']),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Book This Package',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : packages.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No packages available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Packages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Comprehensive health checkups at great prices',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ...packages.map((package) {
              return GestureDetector(
                onTap: () => _showPackageDetails(package),
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(package['color']),
                        Color(package['color']).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(package['color']).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                package['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '₹${package['price']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          package['description'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${(package['tests'] as List).length} tests included',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '~${package['duration']} mins',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Tap for details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
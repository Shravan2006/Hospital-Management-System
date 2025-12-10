// lib/screens/categories/health_packages_screen.dart
import 'package:flutter/material.dart';
import 'package:hospital_app_new/patient/package_detail_screen.dart'; // Reuse your existing detail screen

class HealthPackagesScreen extends StatelessWidget {
  const HealthPackagesScreen({super.key});

  final List<Map<String, dynamic>> packages = const [
    {
      "name": "Full Body Health Checkup",
      "price": "₹4,999",
      "original": "₹8,500",
      "tests": 72,
      "gradient": [Color(0xFF667eea), Color(0xFF764ba2)]
    },
    {
      "name": "Senior Citizen Package",
      "price": "₹3,999",
      "original": "₹7,000",
      "tests": 65,
      "gradient": [Color(0xFF11998e), Color(0xFF38ef7d)]
    },
    {
      "name": "Women Wellness Package",
      "price": "₹5,499",
      "original": "₹10,000",
      "tests": 68,
      "gradient": [Color(0xFFF093FB), Color(0xFFF5576C)]
    },
    {
      "name": "Diabetes Comprehensive",
      "price": "₹2,999",
      "original": "₹5,500",
      "tests": 52,
      "gradient": [Color(0xFF4facfe), Color(0xFF00f2fe)]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Packages"),
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.green.shade700,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, i) {
          final pkg = packages[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: pkg['gradient']),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Text(pkg['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text("${pkg['tests']} Tests Included", style: TextStyle(color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(pkg['price'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      Text(pkg['original'], style: TextStyle(color: Colors.white70, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PackageDetailScreen(package: pkg)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
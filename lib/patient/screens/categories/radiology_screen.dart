// lib/screens/categories/radiology_screen.dart
import 'package:flutter/material.dart';

class RadiologyScreen extends StatelessWidget {
  const RadiologyScreen({super.key});

  final List<Map<String, String>> tests = const [
    {"name": "X-Ray Chest", "price": "₹400"},
    {"name": "X-Ray Spine", "price": "₹600"},
    {"name": "Ultrasound Whole Abdomen", "price": "₹1,200"},
    {"name": "Ultrasound KUB (Kidney, Ureter, Bladder)", "price": "₹1,000"},
    {"name": "CT Scan Brain (Plain)", "price": "₹2,500"},
    {"name": "MRI Brain (Plain)", "price": "₹6,500"},
    {"name": "Mammography (Both Breasts)", "price": "₹1,800"},
    {"name": "DEXA Bone Density Scan", "price": "₹2,200"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Radiology & Imaging"),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search X-Ray, Ultrasound, CT, MRI...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tests.length,
              itemBuilder: (context, i) {
                final test = tests[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.scanner, color: Colors.blue.shade600),
                    title: Text(
                      test["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      test["price"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${test["name"]} added to cart")),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
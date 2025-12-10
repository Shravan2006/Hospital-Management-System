// lib/screens/categories/blood_tests_screen.dart
import 'package:flutter/material.dart';

class BloodTestsScreen extends StatelessWidget {
  const BloodTestsScreen({super.key});

  final List<Map<String, String>> tests = const [
    {"name": "Complete Blood Count (CBC)", "price": "₹350"},
    {"name": "Liver Function Test (LFT)", "price": "₹650"},
    {"name": "Kidney Function Test (KFT)", "price": "₹750"},
    {"name": "Lipid Profile", "price": "₹550"},
    {"name": "Thyroid Profile (T3,T4,TSH)", "price": "₹850"},
    {"name": "HbA1c (Diabetes Check)", "price": "₹450"},
    {"name": "Vitamin B12", "price": "₹950"},
    {"name": "Vitamin D Total", "price": "₹1,299"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Tests"),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search blood tests...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: ListTile(
                    title: Text(test["name"]!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(test["price"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${test["name"]} to cart"))),
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
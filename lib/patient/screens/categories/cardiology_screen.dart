// lib/screens/categories/cardiology_screen.dart
import 'package:flutter/material.dart';

class CardiologyScreen extends StatelessWidget {
  const CardiologyScreen({super.key});

  final List<Map<String, String>> tests = const [
    {"name": "ECG (Electrocardiogram)", "price": "₹350"},
    {"name": "2D Echocardiography (Echo)", "price": "₹1,800"},
    {"name": "Treadmill Test (TMT)", "price": "₹1,500"},
    {"name": "Lipid Profile", "price": "₹550"},
    {"name": "Troponin I (Heart Attack Marker)", "price": "₹1,200"},
    {"name": "BNP / NT-proBNP", "price": "₹2,200"},
    {"name": "Stress Echocardiography", "price": "₹3,500"},
    {"name": "Holter Monitoring (24 hrs)", "price": "₹3,000"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cardiology"),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar (same as Blood Tests)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search ECG, Echo, TMT, Lipid Profile...",
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Test List (same card style as Blood Tests)
          Expanded(
            child: ListView.builder(
              itemCount: tests.length,
              itemBuilder: (context, i) {
                final test = tests[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.favorite,
                      color: Colors.red.shade500,
                      size: 28,
                    ),
                    title: Text(
                      test["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Text(
                      test["price"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${test["name"]} added to cart"),
                          backgroundColor: Colors.purple.shade600,
                        ),
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
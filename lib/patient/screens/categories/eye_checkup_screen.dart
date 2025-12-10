// lib/screens/categories/eye_checkup_screen.dart
import 'package:flutter/material.dart';

class EyeCheckupScreen extends StatelessWidget {
  const EyeCheckupScreen({super.key});

  final List<Map<String, String>> tests = const [
    {"name": "Comprehensive Eye Checkup", "price": "₹800"},
    {"name": "Refraction & Glasses Prescription", "price": "₹500"},
    {"name": "Fundus Examination (Retina Check)", "price": "₹700"},
    {"name": "Tonometry (Glaucoma Test)", "price": "₹400"},
    {"name": "Color Vision Test", "price": "₹300"},
    {"name": "Dry Eye Evaluation", "price": "₹600"},
    {"name": "Cataract Screening", "price": "₹900"},
    {"name": "Computer Vision Syndrome Package", "price": "₹1,200"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eye Checkup"),
        backgroundColor: Colors.teal.shade50,
        foregroundColor: Colors.teal.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search eye tests...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                    leading: Icon(Icons.remove_red_eye, color: Colors.teal.shade600),
                    title: Text(test["name"]!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(test["price"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${test["name"]} booked!")),
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
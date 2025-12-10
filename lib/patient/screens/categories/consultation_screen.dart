// lib/screens/categories/consultation_screen.dart
import 'package:flutter/material.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  final List<Map<String, String>> specialties = const [
    {"name": "General Physician", "doctors": "150+"},
    {"name": "Dermatologist", "doctors": "89+"},
    {"name": "Pediatrician", "doctors": "72+"},
    {"name": "Gynecologist", "doctors": "95+"},
    {"name": "Orthopedic", "doctors": "68+"},
    {"name": "ENT Specialist", "doctors": "54+"},
    {"name": "Psychiatrist", "doctors": "42+"},
    {"name": "Cardiologist", "doctors": "58+"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consult Doctors"),
        backgroundColor: Colors.orange.shade50,
        foregroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search specialty or doctor...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: specialties.length,
              itemBuilder: (context, i) {
                final spec = specialties[i];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Showing ${spec['name']} doctors...")),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_hospital, size: 40, color: Colors.orange.shade600),
                        const SizedBox(height: 12),
                        Text(spec['name']!, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        Text("${spec['doctors']} doctors", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
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
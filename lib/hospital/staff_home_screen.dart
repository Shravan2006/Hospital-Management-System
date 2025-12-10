// lib/screens/staff_home_screen.dart
import 'package:flutter/material.dart';

class StaffHomeScreen extends StatelessWidget {
  final String userName;

  const StaffHomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, $userName"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              "Staff Panel",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              "Management features coming soon",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
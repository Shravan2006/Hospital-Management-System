// lib/screens/appointments_screen.dart
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  // Dummy upcoming appointments (replace with Supabase later)
  final List<Map<String, String>> upcoming = const [
    {"package": "Full Body Checkup", "date": "Dec 12, 2025", "time": "9:00 AM", "status": "Confirmed"},
  ];

  final List<Map<String, String>> past = const [
    {"package": "Diabetes Screening", "date": "Nov 5, 2025", "time": "10:30 AM", "status": "Completed"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Appointments")),
      body: upcoming.isEmpty && past.isEmpty
          ? const Center(child: Text("No appointments yet.\nBook your first health checkup!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (upcoming.isNotEmpty) ...[
            const Text("Upcoming", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...upcoming.map((a) => Card(
              child: ListTile(
                title: Text(a['package']!),
                subtitle: Text("${a['date']} • ${a['time']}"),
                trailing: Chip(label: Text(a['status']!), backgroundColor: Colors.green.shade100),
              ),
            )),
            const SizedBox(height: 20),
          ],
          const Text("Past Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...past.map((a) => Card(
            child: ListTile(
              title: Text(a['package']!),
              subtitle: Text("${a['date']} • ${a['time']}"),
              trailing: Chip(label: Text(a['status']!), backgroundColor: Colors.grey.shade200),
            ),
          )),
        ],
      ),
    );
  }
}
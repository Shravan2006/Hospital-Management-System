// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/services/cart_service.dart';
import 'screens/role_selection_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dtxnkfcmbhhgpazvzaty.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR0eG5rZmNtYmhoZ3BhenZ6YXR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2ODk1NDQsImV4cCI6MjA4MzI2NTU0NH0.SrHEmlOJ3BEF318O3gKikockQzkYMB3MsusBjPAjOWo',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CartService>(
          create: (_) => CartService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Global Supabase client (SAFE & STANDARD)
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management System',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade50,

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
            BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),

      initialRoute: '/role-selection',

      routes: {
        '/role-selection': (_) => RoleSelectionScreen(),
        '/patient-dashboard': (_) => PatientDashboard(),
        '/doctor-dashboard': (_) => DoctorDashboard(),
        '/admin-dashboard': (_) => AdminDashboard(),
      },
    );
  }
}

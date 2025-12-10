// main.dart
import 'package:flutter/material.dart';
import 'package:hospital_app_new/supabase_client.dart'; // Import this
import 'package:hospital_app_new/login/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();     // Required for Supabase

  // Initialize Supabase before running the app
  await SupabaseClientInstance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Hospital',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
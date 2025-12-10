// lib/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientInstance {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://wpftwdjowewhbxeghthz.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwZnR3ZGpvd2V3aGJ4ZWdodGh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5NDQ1NjIsImV4cCI6MjA4MDUyMDU2Mn0.FHjGkpcOKq-12BS0qEQuT898Tk1xScfjkR3DN-eYRek',
    );
  }
}
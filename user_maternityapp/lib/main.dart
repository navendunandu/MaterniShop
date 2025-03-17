import 'package:flutter/material.dart';
import 'package:user_maternityapp/screens/account/auth_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_maternityapp/screens/homepage.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wirqkldfhhfigspgibql.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpcnFrbGRmaGhmaWdzcGdpYnFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDQyMDgsImV4cCI6MjA1MjY4MDIwOH0.cgwClajkw6i1YR4-IFmPBMjMXcXIkWKDDcRMfDR7qks',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // Use a wrapper to handle navigation logic
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return HomeScreen(); // Replace with your home screen widget
    } else {
      return AuthPage(); // Replace with your auth page widget
    }
  }
}

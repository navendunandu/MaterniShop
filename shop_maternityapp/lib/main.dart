import 'package:flutter/material.dart';
import 'package:shop_maternityapp/Landingpage.dart';
import 'package:shop_maternityapp/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final session = supabase.auth.currentSession;

    if (session != null) {
      // User is logged in, navigate to HomePage
      return DashboardPage();
    } else {
      // User is not logged in, navigate to LandingPage
      return LandingPage();
    }
  }
}
import 'package:admin_maternityapp/screen/homepage.dart';
import 'package:flutter/material.dart';

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
    return const MaterialApp(debugShowCheckedModeBanner: false,
      home: Homepage()
    );
  }
}

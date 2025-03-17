import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Welcome to Admin Dashboard",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)
      )
    );
  }
}

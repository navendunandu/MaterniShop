import 'package:admin_maternityapp/main.dart';
import 'package:admin_maternityapp/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> signin() async {
    String email = _emailController.text.trim();
    String password = _passController.text.trim();

    try {
      // Sign in with Supabase Auth
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user == null) {
        throw Exception("User not found after sign-in");
      }
      String uid = user.id;
      print("User ID from Auth: $uid");

      // Check if the user is an admin by querying tbl_admin
      final response = await supabase
          .from("tbl_admin")
          .select('id')
          .eq("id", uid)
          .count(CountOption.exact);
      int count = response.count;
      print("Count of matching admins: $count");

      if (count > 0) {
        // Navigate to the dashboard or home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        // Sign out the user if they are not an admin
        await supabase.auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials")),
        );
      }
    } catch (e) {
      print('Error during signin: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signin failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 252, 88, 132),
              Color.fromARGB(255, 223, 61, 196)
            ], // Replace with your gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            width: 500,
            height: 600,
            child: ListView(
              padding: EdgeInsets.all(50),
              children: [
                Text(
                  "Login",
                  style: TextStyle(fontSize: 50),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Type your Username",
                      labelText: "Username"),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _passController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility),
                      hintText: "Type your Password",
                      labelText: "Password"),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    signin();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 252, 88, 132),
                          Color.fromARGB(255, 223, 61, 196)
                        ], // Gradient colors
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    alignment: Alignment.center, // Centers the text
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

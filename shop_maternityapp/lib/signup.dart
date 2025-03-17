import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Uint8List? _imageBytes;
  PlatformFile? pickedProof;
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedProof = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 240, 255),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               Icon(
                      Icons.baby_changing_station_sharp,
                      color: Color.fromARGB(255, 198, 176, 249),
                      size: 40,
                    ),
                       SizedBox(width: 10),
                Text(
                      "MaterniShop",
                      style: GoogleFonts.aclonica(
                        color: Color.fromARGB(255, 198, 176, 249),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                SizedBox(height: 5),
                Text(
                  'Create an account',
                  style: GoogleFonts.sanchez(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 15),

                // Profile Picture Picker
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 244, 242, 242),
                    child: _imageBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              _imageBytes!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.add_a_photo,
                            size: 40, color:  Color.fromARGB(255, 198, 176, 249)),
                  ),
                ),

                SizedBox(height: 15),

                // Name Input
                customTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  icon: Icons.person,
                   
                ),

                SizedBox(height: 10),

                // Email Input
                customTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email,

                  
                ),

                SizedBox(height: 10),

                // Password Input
                customTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),

                SizedBox(height: 10),

                // Confirm Password Input
                customTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  icon: Icons.lock_reset,
                  obscureText: true,
                ),

                SizedBox(height: 10),

                // Contact Input
                customTextField(
                  controller: _contactController,
                  hintText: 'Contact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 10),

                // Proof Upload
                customTextField(
                  controller: TextEditingController(
                      text: pickedProof != null ? pickedProof!.name : ''),
                  hintText: 'Upload Proof',
                  icon: Icons.file_present,
                  readOnly: true,
                  onTap: handleProofPick,
                ),

                SizedBox(height: 20),

                // Signup Button
                ElevatedButton(
                  onPressed: () {
                    // Handle Sign Up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 198, 176, 249),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                SizedBox(height: 10),

                // Navigate to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",style: GoogleFonts.sanchez(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),),
                    TextButton(
                      onPressed: () {
                        // Navigate to Login Page
                      },
                      child: Text(
                        'Login',
                       style: GoogleFonts.sanchez(
                    fontSize: 16,
                    color: Color.fromARGB(255, 138, 101, 202),
                  ),
                        ),
                      ),
                    
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Function()? onTap,
  }) {
    return SizedBox(
      width: 350,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 138, 101, 202)),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color.fromARGB(255, 245, 240, 255),
        ),
      ),
    );
  }
}

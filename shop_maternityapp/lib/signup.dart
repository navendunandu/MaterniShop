import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shop_maternityapp/login.dart';
import 'package:intl/intl.dart';
import 'package:shop_maternityapp/main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Uint8List? _imageBytes;
  PlatformFile? pickedProof;
  final picker = ImagePicker();
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];
  String? selectedDistrict;
  String? selectedPlace;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _proofController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

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
        _proofController.text = result.files.first.name;
      });
    }
  }

  Future<String?> uploadImage() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first!')),
      );
      return "";
    }

    try {
      final String fileName =
          'shop_photos/${DateTime.now().millisecondsSinceEpoch}.png';
      await supabase.storage.from('shop').uploadBinary(fileName, _imageBytes!);
      final imageUrl = supabase.storage.from('shop').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image Upload Failed!')),
      );
      return null;
    }
  }

  Future<String?> proofUpload() async {
    if (pickedProof == null) return null;
    try {
      final bucketName = 'shop';
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${pickedProof!.name}";
      await supabase.storage.from(bucketName).uploadBinary(filePath, pickedProof!.bytes!);
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proof Upload Failed!')),
      );
      return null;
    }
  }

  Future<void> register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    try {
      final authentication = await supabase.auth.signUp(
        password: _passwordController.text,
        email: _emailController.text,
      );
      String uid = authentication.user!.id;
      await insertShop(uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
  }

  Future<void> insertShop(String uid) async {
    try {
      String? imageUrl = await uploadImage();
      String? proofUrl = await proofUpload();
      await supabase.from("tbl_shop").insert({
        'shop_name': _nameController.text,
        'shop_password': _passwordController.text,
        'shop_address': _addressController.text,
        'shop_contact': _contactController.text,
        'shop_email': _emailController.text,
        'place_id': selectedPlace,
        'shop_logo': imageUrl,
        'shop_proof': proofUrl,
      });

      clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Inserting Shop: $e')),
      );
    }
  }

  void clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _contactController.clear();
    _addressController.clear();
    _proofController.clear();
    setState(() {
      _imageBytes = null;
      pickedProof = null;
      selectedDistrict = null;
      selectedPlace = null;
    });
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        districts = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching District: $e");
    }
  }

  Future<void> fetchPlace(String id) async {
    try {
      final response = await supabase.from("tbl_place").select().eq('district_id', id);
      setState(() {
        places = response;
      });
    } catch (e) {
      print("Error fetching Places: $e");
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
            child: Form(
              key: formKey,
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
                      backgroundColor: Color.fromARGB(255, 244, 242, 242),
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
                              size: 40, color: Color.fromARGB(255, 198, 176, 249)),
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

                  // Address Input
                  customTextField(
                    controller: _addressController,
                    hintText: 'Address',
                    icon: Icons.home,
                  ),

                  SizedBox(height: 10),

                  // District Dropdown
                  SizedBox(
                    width: 350,
                    child: DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      hint: Text("Select District"),
                      items: districts.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['district_id'].toString(),
                          child: Text(data['district_name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                          selectedPlace = null; // Reset place when district changes
                          places = []; // Clear previous places
                        });
                        if (newValue != null) fetchPlace(newValue);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_city,
                            color: Color.fromARGB(255, 138, 101, 202)),
                        hintText: 'District',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 245, 240, 255),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Place Dropdown
                  SizedBox(
                    width: 350,
                    child: DropdownButtonFormField<String>(
                      value: selectedPlace,
                      hint: Text("Select Place"),
                      items: places.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'].toString(),
                          child: Text(data['place_name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPlace = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.place,
                            color: Color.fromARGB(255, 138, 101, 202)),
                        hintText: 'Place',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 245, 240, 255),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Proof Upload
                  customTextField(
                    controller: _proofController,
                    hintText: 'Upload Proof',
                    icon: Icons.file_present,
                    readOnly: true,
                    onTap: handleProofPick,
                  ),

                  SizedBox(height: 20),

                  // Signup Button
                  ElevatedButton(
                    onPressed: register,
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
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.sanchez(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
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
// auth_page.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_maternityapp/components/colors.dart';
import 'package:user_maternityapp/components/form_validation.dart';
import 'package:user_maternityapp/screens/homepage.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/screens/account/pregnency_date.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 228, 232, 252),
                Color.fromARGB(255, 187, 193, 248),
                Color.fromARGB(255, 245, 245, 245),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/strock.json', height: 200),
                      Text(
                        "Mamasphere",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Your pregnancy journey companion",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorColor: Color.fromARGB(255, 140, 179, 248),
                    indicatorWeight: 5,
                    labelColor: Color.fromARGB(255, 140, 179, 248),
                    unselectedLabelColor: Colors.white,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    tabs: const [
                      Tab(text: "Sign In"),
                      Tab(
                        text: "Sign Up",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      const LoginForm(),
                      RegisterForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Login Form
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> login() async {
    try {
      final response = await supabase.auth.signInWithPassword(
          password: _passController.text, email: _emailController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      print("Error logining user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:  30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 30,
                ),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  validator: _validateEmail,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color(0xFF757575)),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Color.fromARGB(255, 140, 179, 248)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color.fromARGB(255, 140, 179, 248),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 140, 179, 248),
                          width: 1.5),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 15),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       // Forgot password functionality
                //     },
                //     child: Text(
                //       'Forgot Password?',
                //       style: GoogleFonts.poppins(
                //         color: Color.fromARGB(255, 140, 179, 248),
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 140, 179, 248),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor:
                        Color.fromARGB(255, 140, 179, 248).withOpacity(0.5),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        DefaultTabController.of(context).animateTo(1);
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 140, 179, 248),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Register Form
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _cpassController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> register() async {
    try {
      final response = await supabase.auth
          .signUp(password: _passController.text, email: _emailController.text);
      String userid = response.user!.id;
      storeData(userid);
    } catch (e) {
      print("Error registering user: $e");
    }
  }

  Future<void> storeData(String uid) async {
    try {
      await supabase.from("tbl_user").insert({
        'id': uid,
        'user_name': _nameController.text,
        'user_email': _emailController.text,
        'user_password': _passController.text,
        'user_contact': _contactController.text,
        'user_address': _addressController.text,
        'user_dob': _dobController.text,
      });
      _nameController.clear();
      _emailController.clear();
      _passController.clear();
      _cpassController.clear();
      _contactController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration Successful"),
        backgroundColor: Color.fromARGB(255, 140, 179, 248),
      ));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PregnancyDatePicker(),
          ));
    } catch (e) {
      print("Error storing data:$e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime eighteenYearsAgo =
        DateTime.now().subtract(Duration(days: 18 * 365));

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 140, 179, 248),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dobController.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (p0) => FormValidation.validateName(p0),
                  controller: _nameController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  validator: (p0) => FormValidation.validateEmail(p0),
                  controller: _emailController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  validator: (p0) => FormValidation.validateAddress(p0),
                  controller: _addressController,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  validator: (p0) => FormValidation.validateContact(p0),
                  controller: _contactController,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Color(0xFF757575)),
                    prefixIcon: Icon(Icons.calendar_today,
                        color: Color.fromARGB(255, 140, 179, 248)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 140, 179, 248),
                          width: 1.5),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                  validator: _validateDOB,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color(0xFF757575)),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Color.fromARGB(255, 140, 179, 248)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color.fromARGB(255, 140, 179, 248),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 140, 179, 248),
                          width: 1.5),
                    ),
                  ),
                  validator: (p0) => FormValidation.validatePassword(p0),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _cpassController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Color(0xFF757575)),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Color.fromARGB(255, 140, 179, 248)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color.fromARGB(255, 140, 179, 248),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 140, 179, 248),
                          width: 1.5),
                    ),
                  ),
                  validator: (p0) => FormValidation.validateConfirmPassword(
                      p0, _passController.text),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 140, 179, 248),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor:
                        Color.fromARGB(255, 140, 179, 248).withOpacity(0.5),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      register();
                    }
                  },
                  child: Text(
                    "Register",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        DefaultTabController.of(context).animateTo(0);
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 140, 179, 248),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Common Text Field Widget with Validation
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF757575)),
      prefixIcon: Icon(icon, color: Color.fromARGB(255, 140, 179, 248)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide:
            BorderSide(color: Color.fromARGB(255, 140, 179, 248), width: 1.5),
      ),
    ),
    obscureText: obscureText,
    validator: validator,
  );
}

// Validation Functions
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? _validateDOB(String? value) {
  if (value == null || value.isEmpty) {
    return 'Date of Birth is required';
  }
  DateTime dob = DateTime.parse(value);
  DateTime today = DateTime.now();
  int age = today.year - dob.year;
  if (today.month < dob.month ||
      (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  if (age < 18) {
    return 'You must be at least 18 years old';
  }
  return null;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_maternityapp/main.dart';
import 'package:intl/intl.dart';
import 'package:user_maternityapp/screens/account/change_password.dart';
import 'package:user_maternityapp/screens/account/editprofile.dart';
import 'package:user_maternityapp/screens/shopping/my_order.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser?.id ?? '';
      if (uid.isEmpty) return;
      final response = await supabase.from('tbl_user').select().eq('id', uid).single();
      setState(() {
        user = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int calculateAge(String? dob) {
    if (dob == null) return 0;
    DateTime birthDate = DateTime.parse(dob);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String calculatePregnancyDuration(String? pregnancyDate) {
    if (pregnancyDate == null) return 'Not Pregnant';
    DateTime startDate = DateTime.parse(pregnancyDate);
    Duration diff = DateTime.now().difference(startDate);
    int weeks = diff.inDays ~/ 7;
    int days = diff.inDays % 7;
    return '$weeks weeks, $days days';
  }

  String calculateDueDate(String? pregnancyDate) {
    if (pregnancyDate == null) return 'N/A';
    DateTime startDate = DateTime.parse(pregnancyDate);
    DateTime dueDate = startDate.add(Duration(days: 280)); // 40 weeks
    return DateFormat('MMM dd, yyyy').format(dueDate);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: Colors.blue[400])),
              onPressed: () async {
                await supabase.auth.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[400]))
          : user == null
              ? Center(child: Text('User not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.blue[400],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'My Profile',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Colors.blue.shade400, const Color.fromARGB(255, 118, 163, 200)],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    user!['user_name']?[0].toUpperCase() ?? '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      color: Colors.blue[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditprofilePage(),
                              ),
                            ).then((_) => fetchUser());
                          },
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    user!['user_name'] ?? 'Unknown',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 66, 165, 245).withOpacity(.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      calculatePregnancyDuration(user!['user_pregnancy_date']),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.blue[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Personal Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildInfoCard(
                              'Name',
                              user!['user_name'] ?? 'Not set',
                              Icons.person,
                            ),
                            _buildInfoCard(
                              'Email',
                              user!['user_email'] ?? 'Not set',
                              Icons.email,
                            ),
                            _buildInfoCard(
                              'Phone',
                              user!['user_contact'] ?? 'Not set',
                              Icons.phone,
                            ),
                            _buildInfoCard(
                              'Age',
                              '${calculateAge(user!['user_dob'])} years',
                              Icons.cake,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Pregnancy Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildInfoCard(
                              'Pregnancy Start',
                              user!['user_pregnancy_date'] != null
                                  ? DateFormat('MMM dd, yyyy').format(DateTime.parse(user!['user_pregnancy_date']))
                                  : 'Not set',
                              Icons.calendar_today,
                            ),
                            _buildInfoCard(
                              'Due Date',
                              calculateDueDate(user!['user_pregnancy_date']),
                              Icons.event_available,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Account',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildActionButton(
                              'My Bookings',
                              Icons.calendar_month,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrdersPage()),
                                );
                              },
                            ),
                            _buildActionButton(
                              'Change Password',
                              Icons.lock,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                                );
                              },
                            ),
                            _buildActionButton(
                              'Logout',
                              Icons.exit_to_app,
                              _showLogoutDialog,
                              isLogout: true,
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 66, 165, 245).withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue[400]),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed, {bool isLogout = false}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLogout
                      ? const Color.fromARGB(255, 66, 165, 245).withOpacity(.1)
                      : const Color.fromARGB(255, 66, 165, 245).withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.blue[400] : Colors.blue[400],
                ),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.blue[400] : Colors.black87,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
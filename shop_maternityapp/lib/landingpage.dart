import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shop_maternityapp/login.dart';
import 'package:shop_maternityapp/signup.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 198, 176, 249),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Logo Goes Here
                  Row(
                    children: [
                      Icon(Icons.baby_changing_station, color: Colors.white, size: 30),
                      SizedBox(width: 8),
                      Text(
                        "MaterniShop",
                        style: GoogleFonts.aclonica(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => Homepage(),
                            //     ));
                          },
                          child: Text(
                            'Home',
                            style: GoogleFonts.aclonica(
                                color: Colors.white, fontSize: 15),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ));
                          },
                          child: Text(
                            'SignUp',
                            style: GoogleFonts.aclonica(
                                color: Colors.white, fontSize: 15),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ));
                          },
                          child: Text(
                            'Login',
                            style: GoogleFonts.aclonica(
                                color: Colors.white, fontSize: 15),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            
            // Hero Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Life Begin',
                          style: GoogleFonts.italiana(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'Cherishing Motherhood, Every Step of the Way',
                          style: GoogleFonts.sanchez(
                              fontSize: 25,
                              fontWeight: FontWeight.w100,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.aDLaMDisplay(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(right: 40, top: 50),
                    child: Lottie.asset('Assets/pregnentwomen.json',
                        fit: BoxFit.cover,
                        width: 450,
                        alignment: Alignment.center)),
              ],
            ),
            
            // Features Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    'Why Choose MaterniShop?',
                    style: GoogleFonts.italiana(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 198, 176, 249),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Manage your maternity shop with ease and connect with expecting mothers',
                    style: GoogleFonts.sanchez(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.inventory_2,
                        title: 'Product Management',
                        description: 'Easily upload and manage your maternity products',
                      ),
                      _buildFeatureCard(
                        icon: Icons.calendar_month,
                        title: 'Booking System',
                        description: 'Manage appointments and consultations',
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics,
                        title: 'Sales Analytics',
                        description: 'Track your sales and customer engagement',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Testimonials Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
              color: Color.fromARGB(255, 240, 234, 255),
              child: Column(
                children: [
                  Text(
                    'What Shop Owners Say',
                    style: GoogleFonts.italiana(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 198, 176, 249),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTestimonialCard(
                        name: 'Sarah Johnson',
                        role: 'Owner, Baby Bliss',
                        testimonial: 'MaterniShop has transformed how I manage my maternity store. The booking system is a game-changer!',
                      ),
                      _buildTestimonialCard(
                        name: 'Michael Chen',
                        role: 'Manager, Mom & Me',
                        testimonial: 'The analytics feature helps me understand what products are most popular with expecting mothers.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Call to Action
            Container(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
              color: Color.fromARGB(255, 198, 176, 249),
              child: Column(
                children: [
                  Text(
                    'Ready to Grow Your Maternity Business?',
                    style: GoogleFonts.italiana(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Join thousands of maternity shops already using our platform',
                    style: GoogleFonts.sanchez(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Sign Up Now",
                          style: GoogleFonts.aDLaMDisplay(
                            color: Color.fromARGB(255, 198, 176, 249),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Learn More",
                          style: GoogleFonts.aDLaMDisplay(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              color: Color.fromARGB(255, 150, 123, 211),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.baby_changing_station, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "MaterniShop",
                                style: GoogleFonts.aclonica(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Supporting maternity shops and expecting mothers",
                            style: GoogleFonts.sanchez(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.facebook, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.insert_page_break_rounded, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.email, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  SizedBox(height: 20),
                  Text(
                    "© 2025 MaterniShop. All rights reserved.",
                    style: GoogleFonts.sanchez(
                      color: Colors.white,
                      fontSize: 14,
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
  
  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 50,
            color: Color.fromARGB(255, 198, 176, 249),
          ),
          SizedBox(height: 15),
          Text(
            title,
            style: GoogleFonts.sanchez(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.sanchez(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestimonialCard({required String name, required String role, required String testimonial}) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            size: 40,
            color: Color.fromARGB(255, 198, 176, 249),
          ),
          SizedBox(height: 15),
          Text(
            testimonial,
            style: GoogleFonts.sanchez(
              fontSize: 16,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            name,
            style: GoogleFonts.sanchez(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            role,
            style: GoogleFonts.sanchez(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
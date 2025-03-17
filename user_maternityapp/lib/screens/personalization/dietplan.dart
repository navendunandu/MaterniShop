// diet_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_maternityapp/components/colors.dart';
import 'package:user_maternityapp/main.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  _DietPlanScreenState createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  List<Map<String, dynamic>> dietPlans = [];
  bool isLoading = true;
  int currentTrimester = 1;
  String trimesterName = "First Trimester";

  @override
  void initState() {
    super.initState();
    fetchDietPlans();
  }

  Future<void> fetchDietPlans() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final user = await supabase
          .from('tbl_user')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();

      DateTime pregnancyDate = DateTime.parse(user['user_pregnancy_date']);
      DateTime currentDate = DateTime.now();
      int weeksPregnant = currentDate.difference(pregnancyDate).inDays ~/ 7;
      int trimester = (weeksPregnant ~/ 13) + 1;

      if (trimester < 1) trimester = 1;
      if (trimester > 3) trimester = 3;

      setState(() {
        currentTrimester = trimester;
        switch (trimester) {
          case 1:
            trimesterName = "First Trimester";
            break;
          case 2:
            trimesterName = "Second Trimester";
            break;
          case 3:
            trimesterName = "Third Trimester";
            break;
        }
      });

      final response = await supabase
          .from('tbl_dietplan')
          .select()
          .eq('dietplan_month', trimester);

      setState(() {
        dietPlans = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching diet plans: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Nutrition Guide",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : dietPlans.isEmpty
                    ? _buildEmptyState()
                    : _buildDietPlansList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trimesterName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Healthy Eating for You & Baby",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Nutrition plans tailored to your pregnancy stage",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            "No diet plans available",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please check back later",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlansList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: dietPlans.length,
      itemBuilder: (context, index) {
        final diet = dietPlans[index];
        return DietPlanCard(diet: diet);
      },
    );
  }
}

class DietPlanCard extends StatelessWidget {
  final Map<String, dynamic> diet;

  const DietPlanCard({super.key, required this.diet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, Color.fromARGB(255, 215, 112, 206)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diet['dietplan_title'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Trimester ${diet['dietplan_month']} Nutrition",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diet['dietplan_description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                _buildMealSection("Breakfast", diet['dietplan_breakfast'], Icons.wb_sunny_outlined, Color(0xFFFFC107)),
                SizedBox(height: 12),
                _buildMealSection("Lunch", diet['dietplan_lunch'], Icons.cloud_outlined, Color(0xFF64B5F6)),
                SizedBox(height: 12),
                _buildMealSection("Dinner", diet['dietplan_dinner'], Icons.nightlight_outlined, Color(0xFF9575CD)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
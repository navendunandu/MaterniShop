// home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_maternityapp/components/colors.dart';
import 'package:user_maternityapp/screens/personalization/dietplan.dart';
import 'package:user_maternityapp/screens/personalization/exercise.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/screens/account/profilepage.dart';
import 'package:user_maternityapp/screens/shopping/shopping.dart';
import 'package:user_maternityapp/screens/community/viewpost.dart';
import 'package:user_maternityapp/screens/personalization/weighttracker.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track current week of pregnancy (this would come from your data)
  int currentWeek = 0;
  int totalWeeks = 40;

  // Current baby size comparison
  String babySizeComparison = "Honeydew Melon";

  // Daily tip
  String dailyTip =
      "Try gentle stretching before bed to help with sleep quality.";

  String babyDevelopment =
      "Your baby is growing tiny fingers and toes this week.";

  Future<void> fetchData() async {
  try {
    final response = await supabase
        .from('tbl_user')
        .select()
        .eq('id', supabase.auth.currentUser!.id)
        .single();

    DateTime pregnancyDate = DateTime.parse(response['user_pregnancy_date']);
    DateTime currentDate = DateTime.now();
    int weeksPregnant = currentDate.difference(pregnancyDate).inDays ~/ 7;
    // int trimester = (weeksPregnant ~/ 13) + 1;

    String babyDevelopmentText = getBabyDevelopmentText(weeksPregnant);
    String dailyTipText = getDailyTip(weeksPregnant);
    String babySize = getBabySize(weeksPregnant);

    setState(() {
      currentWeek = weeksPregnant;
      totalWeeks = 40;
      babyDevelopment = babyDevelopmentText;
      dailyTip = dailyTipText;
      babySizeComparison = babySize;
    });
  } catch (e) {
    print("Error fetching pregnancy data: $e");
  }
}

String getBabySize(int week) {
  List<String> sizes = [
    "Poppy Seed", "Sesame Seed", "Lentil", "Blueberry", "Raspberry",
    "Cherry", "Strawberry", "Lime", "Plum", "Peach", "Lemon", "Apple",
    "Avocado", "Onion", "Sweet Potato", "Mango", "Banana", "Carrot",
    "Papaya", "Grapefruit", "Cantaloupe", "Cauliflower", "Butternut Squash",
    "Eggplant", "Lettuce Head", "Acorn Squash", "Cabbage", "Coconut",
    "Jicama", "Pineapple", "Cantaloupe", "Honeydew Melon", "Romaine Lettuce",
    "Swiss Chard", "Pumpkin", "Watermelon", "Small Pumpkin"
  ];
  
  if (week < 4) return "Too small to measure!";
  if (week >= 40) return "Almost here!";
  
  return sizes[week - 4]; // Adjusting index since week 4 is the first in the list
}


String getBabyDevelopmentText(int week) {
  if (week < 6) return "Your baby's heart has started beating!";
  if (week < 12) return "Your baby is growing tiny fingers and toes.";
  if (week < 18) return "Your baby can hear your voice!";
  if (week < 24) return "Your baby responds to sounds and light.";
  if (week < 30) return "Your baby's lungs are developing for life outside.";
  if (week < 36) return "Your baby is gaining weight and getting ready for birth.";
  return "Your baby is fully developed and ready to meet you soon!";
}

String getDailyTip(int week) {
  if (week < 10) return "Stay hydrated and take prenatal vitamins daily.";
  if (week < 20) return "Try gentle stretching before bed for better sleep.";
  if (week < 30) return "Practice good posture to reduce lower back pain.";
  return "Get plenty of rest and prepare your hospital bag!";
}


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildProgressTracker(),
              _buildBabyDevelopment(),
              _buildDailyTip(),
              _buildFeatureGrid(context),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Mommy 💖',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                'Week $currentWeek of $totalWeeks',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromARGB(255, 228, 232, 252),
                child: Icon(Icons.person, color: primaryColor, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    double progress = currentWeek / totalWeeks;

    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color.fromARGB(255, 230, 129, 201)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalWeeks - currentWeek} weeks to go! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.favorite, color: Colors.white, size: 24),
            ],
          ),
          SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week 1',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                'Week $currentWeek',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Week 40',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBabyDevelopment() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
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
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset('assets/strock.json', fit: BoxFit.contain),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Baby This Week',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Size: $babySizeComparison',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your baby is developing rapidly and gaining weight. Their lungs are nearly fully mature.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF90CAF9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFF64B5F6), size: 24),
              SizedBox(width: 10),
              Text(
                'Daily Tip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            dailyTip,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildFeatureTile(
                context,
                'Exercise',
                'Stay fit with safe prenatal workouts',
                Icons.fitness_center,
                Color(0xFFE57BB1),
                Color(0xFFFCE4EC),
                ExerciseScreen(),
              ),
              _buildFeatureTile(
                context,
                'Diet Plans',
                'Nutritious meals for you and baby',
                Icons.restaurant_menu,
                Color(0xFF64B5F6),
                Color(0xFFE3F2FD),
                DietPlanScreen(),
              ),
              _buildFeatureTile(
                context,
                'Weight Tracker',
                'Monitor your pregnancy weight',
                Icons.monitor_weight,
                Color(0xFF81C784),
                Color(0xFFE8F5E9),
                WeightTrackingPage(),
              ),
              _buildFeatureTile(
                context,
                'Shopping',
                'Essential items for mom and baby',
                Icons.shopping_bag,
                Color(0xFFFFB74D),
                Color(0xFFFFF3E0),
                ShoppingPage(),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildCommunitySection(context),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color bgColor,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: EdgeInsets.all(15),
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
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 5),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Viewpost()));
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9575CD), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9575CD).withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join the Community',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Share your journey and connect with other moms',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.add_a_photo, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

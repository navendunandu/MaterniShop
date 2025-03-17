import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_maternityapp/main.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  Map<String, dynamic>? accountData;
  bool isLoading = true;

  Future<void> fetchAccountData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('tbl_shop')
          .select()
          .eq('shop_id', user.id)
          .single();

      setState(() {
        accountData = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        accountData = null;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 250),
      appBar: AppBar(
        title: Text(
          "Account Management",
          style: GoogleFonts.sanchez(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: fetchAccountData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : accountData == null
              ? Center(
                  child: Text(
                    "No shop data found",
                    style: GoogleFonts.sanchez(fontSize: 18, color: Colors.black54),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard("Shop Name", accountData!['shop_name'] ?? 'Not available'),
                      _buildInfoCard("Email", accountData!['shop_email'] ?? 'Not available'),
                      _buildInfoCard("Contact", accountData!['shop_contact'] ?? 'Not available'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sanchez(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.sanchez(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_maternityapp/main.dart';
import 'package:shop_maternityapp/post_complaint.dart';
import 'package:intl/intl.dart';

class ShopComplaintsPage extends StatefulWidget {
  const ShopComplaintsPage({super.key});

  @override
  State<ShopComplaintsPage> createState() => _ShopComplaintsPageState();
}

class _ShopComplaintsPageState extends State<ShopComplaintsPage> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final shopId = supabase.auth.currentUser!.id;
      
      final response = await supabase
          .from('tbl_complaint')
          .select('*')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      
      setState(() {
        complaints = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getStatusText(int status) {
    return status == 0 ? 'Pending' : 'Replied';
  }

  Color getStatusColor(int status) {
    return status == 0 ? Colors.orange : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 250),
      appBar: AppBar(
        title: Text(
          "My Complaints",
          style: GoogleFonts.sanchez(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostComplaintPage()),
          );
          fetchComplaints(); // Refresh the list after returning
        },
        backgroundColor: Color.fromARGB(255, 198, 176, 249),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.feedback_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No complaints yet",
                        style: GoogleFonts.sanchez(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap the + button to post a complaint",
                        style: GoogleFonts.sanchez(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    final DateTime createdAt = DateTime.parse(complaint['created_at']);
                    final String formattedDate = DateFormat('MMM dd, yyyy').format(createdAt);
                    
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    complaint['complaint_title'],
                                    style: GoogleFonts.sanchez(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(complaint['complaint_status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    getStatusText(complaint['complaint_status']),
                                    style: TextStyle(
                                      color: getStatusColor(complaint['complaint_status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Posted on $formattedDate",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              complaint['complaint_content'],
                              style: TextStyle(fontSize: 14),
                            ),
                            if (complaint['complaint_status'] == 1 && complaint['complaint_reply'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(height: 24),
                                  Text(
                                    "Admin Reply:",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green[100]!),
                                    ),
                                    child: Text(
                                      complaint['complaint_reply'],
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

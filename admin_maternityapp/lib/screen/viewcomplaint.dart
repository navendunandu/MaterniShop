import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For formatting dates

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  ComplaintScreenState createState() => ComplaintScreenState();
}

class ComplaintScreenState extends State<ComplaintScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _replyController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  // Get user complaints
  Future<List<Map<String, dynamic>>> _getUserComplaints() async {
    try {
      final response = await _supabase
          .from('tbl_complaint')
          .select('*, tbl_user(user_name)')
          .order('created_at', ascending: false);

      // Filter to keep only user complaints (where user_id is not null and shop_id is null)
      final filteredResponse = List<Map<String, dynamic>>.from(response)
          .where((complaint) => 
              complaint['user_id'] != null && 
              complaint['shop_id'] == null && complaint['product_id'] == null)
          .toList();

      print("User Complaints: $filteredResponse");
      return filteredResponse;
    } catch (e) {
      print("Error fetching user complaints: $e");
      return [];
    }
  }

  // Get shop complaints
  Future<List<Map<String, dynamic>>> _getShopComplaints() async {
    try {
      final response = await _supabase
          .from('tbl_complaint')
          .select('*, tbl_shop(shop_name)')
          .order('created_at', ascending: false);

      // Filter to keep only shop complaints (where shop_id is not null and user_id is null)
      final filteredResponse = List<Map<String, dynamic>>.from(response)
          .where((complaint) => 
              complaint['shop_id'] != null)
          .toList();

      print("Shop Complaints: $filteredResponse");
      return filteredResponse;
    } catch (e) {
      print("Error fetching shop complaints: $e");
      return [];
    }
  }



  // Send reply to user complaint
  Future<void> _sendUserReply(int complaintId, String newReply) async {
    if (newReply.trim().isEmpty) return; // Prevent empty replies

    try {
      // Fetch existing reply
      final response = await _supabase
          .from('tbl_complaint')
          .select('complaint_reply')
          .eq('complaint_id', complaintId)
          .single();

      String existingReply = response['complaint_reply'] ?? "";

      // Append new reply while keeping existing ones
      String updatedReply =
          existingReply.isEmpty ? newReply : "$existingReply\n\n$newReply";

      // Update in the database
      await _supabase.from('tbl_complaint').update({
        'complaint_reply': updatedReply,
        'complaint_status': 1
      }).match({'complaint_id': complaintId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reply sent successfully!")),
      );

      setState(() {}); // Refresh the UI
    } catch (e) {
      print("Error sending reply: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reply. Please try again.")),
      );
    }
  }

  // Send reply to shop complaint
  Future<void> _sendShopReply(int complaintId, String newReply) async {
    if (newReply.trim().isEmpty) return; // Prevent empty replies

    try {
      // Fetch existing reply
      final response = await _supabase
          .from('tbl_complaint')
          .select('complaint_reply')
          .eq('complaint_id', complaintId)
          .single();

      String existingReply = response['complaint_reply'] ?? "";

      // Append new reply while keeping existing ones
      String updatedReply =
          existingReply.isEmpty ? newReply : "$existingReply\n\n$newReply";

      // Update in the database
      await _supabase.from('tbl_complaint').update({
        'complaint_reply': updatedReply,
        'complaint_status': 1
      }).match({'complaint_id': complaintId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reply sent to shop successfully!")),
      );

      setState(() {}); // Refresh the UI
    } catch (e) {
      print("Error sending reply to shop: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reply. Please try again.")),
      );
    }
  }

  // Show reply dialog for user complaints
  void _showUserReplyDialog(int complaintId) {
    _replyController.clear(); // Clear previous input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to User Complaint"),
          content: TextField(
            controller: _replyController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter your reply",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _sendUserReply(complaintId, _replyController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 182, 152, 251),
              ),
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  // Show reply dialog for shop complaints
  void _showShopReplyDialog(int complaintId) {
    _replyController.clear(); // Clear previous input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to Shop Complaint"),
          content: TextField(
            controller: _replyController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter your reply",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _sendShopReply(complaintId, _replyController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 182, 152, 251),
              ),
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
        backgroundColor: Color.fromARGB(255, 182, 152, 251),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "User Complaints"),
            Tab(text: "Shop Complaints"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // User Complaints Tab
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getUserComplaints(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No user complaints yet.'));
              } else {
                final complaints = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  complaint['tbl_user']['user_name'] ?? 'Unknown User',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: complaint['complaint_status'] == 0 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    complaint['complaint_status'] == 0 ? "Pending" : "Replied",
                                    style: TextStyle(
                                      color: complaint['complaint_status'] == 0 ? Colors.orange : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              complaint['complaint_title'] ?? 'No title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              complaint['complaint_content'] ?? 'No content available',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              complaint['created_at'] != null
                                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(complaint['created_at']))
                                  : 'Unknown Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Divider(),
                            if (complaint['complaint_status'] == 1 && complaint['complaint_reply'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Admin Reply:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green[100]!),
                                    ),
                                    child: Text(
                                      complaint['complaint_reply'] ?? '',
                                      style: TextStyle(color: Colors.green[700]),
                                    ),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.reply),
                                  label: Text(complaint['complaint_status'] == 0 ? "Reply" : "Add Reply"),
                                  onPressed: () {
                                    _showUserReplyDialog(complaint['complaint_id']);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),

          // Shop Complaints Tab
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getShopComplaints(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No shop complaints yet.'));
              } else {
                final complaints = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    final DateTime createdAt = DateTime.parse(complaint['created_at']);
                    final String formattedDate = DateFormat('MMM dd, yyyy').format(createdAt);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  complaint['tbl_shop']['shop_name'] ?? 'Unknown Shop',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: complaint['complaint_status'] == 0 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    complaint['complaint_status'] == 0 ? "Pending" : "Replied",
                                    style: TextStyle(
                                      color: complaint['complaint_status'] == 0 ? Colors.orange : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              complaint['complaint_title'] ?? 'No title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              complaint['complaint_content'] ?? 'No content available',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Divider(),
                            if (complaint['complaint_status'] == 1 && complaint['complaint_reply'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Admin Reply:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green[100]!),
                                    ),
                                    child: Text(
                                      complaint['complaint_reply'] ?? '',
                                      style: TextStyle(color: Colors.green[700]),
                                    ),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.reply),
                                  label: Text(complaint['complaint_status'] == 0 ? "Reply" : "Add Reply"),
                                  onPressed: () {
                                    _showShopReplyDialog(complaint['complaint_id']);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

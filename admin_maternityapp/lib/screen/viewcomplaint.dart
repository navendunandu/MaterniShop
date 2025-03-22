import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For formatting dates

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _replyController = TextEditingController();

  Future<List<Map<String, dynamic>>> _getComplaints() async {
    try {
      final response = await _supabase
          .from('tbl_complaint')
          .select('*, tbl_user(user_name)')
          .order('complaint_date', ascending: false);

      print("Raw Complaints Data: $response");

      if (response.isEmpty) {
        print("No complaints found.");
        return [];
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching complaints: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _getComplaints();
  }

  Future<void> _sendReply(int complaintId, String newReply) async {
    if (newReply.trim().isEmpty) return; // Prevent empty replies

    try {
      print("Replying to complaint ID: $complaintId with message: $newReply");

      // Fetch existing reply
      final response = await _supabase
          .from('tbl_complaint')
          .select('complaint_reply')
          .eq('complaint_id', complaintId) // Ensure correct column name
          .single();

      String existingReply = response['complaint_reply'] ?? "";

      // Append new reply while keeping existing ones
      String updatedReply =
          existingReply.isEmpty ? newReply : "$existingReply\n\n$newReply";

      // Update in the database
      final updateResponse = await _supabase.from('tbl_complaint').update({
        'complaint_reply': updatedReply,
        'complaint_status': 1
      }).match({'complaint_id': complaintId}); // Ensure correct column name

      print("Update response: $updateResponse");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reply sent successfully!")),
      );

      setState(() {}); // Refresh the UI
    } catch (e) {
      print("Error sending reply: $e");
    }
  }

  void _showReplyDialog(int complaintId) {
    _replyController.clear(); // Clear previous input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to Complaint"),
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
                _sendReply(complaintId, _replyController.text);
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No complaints yet.'));
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
                      Text(
                        complaint['tbl_user']['user_name'] ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        complaint['complaint_content'] ??
                            'No content available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          complaint['complaint_status'] == 0
                              ? TextButton(
                                  onPressed: () {
                                    _showReplyDialog(complaint[
                                        'complaint_id']); // Fix complaint ID reference
                                  },
                                  child: Text("Reply"))
                              : Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Replied:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        complaint['complaint_reply'] ?? '',
                                        style:
                                            TextStyle(color: Colors.green[700]),
                                      ),
                                      SizedBox(height: 5),
                                      TextButton(
                                        onPressed: () {
                                          _showReplyDialog(complaint[
                                              'complaint_id']); // Fix complaint ID reference
                                        },
                                        child: Text("Add Reply"),
                                      ),
                                    ],
                                  ),
                                ),
                          Text(
                            complaint['complaint_date'] != null
                                ? DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(complaint['complaint_date']))
                                : 'Unknown Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
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
    );
  }
}
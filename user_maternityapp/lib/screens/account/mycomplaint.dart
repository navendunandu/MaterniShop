import 'package:flutter/material.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/components/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PostComplaint extends StatefulWidget {
  const PostComplaint({super.key});

  @override
  State<PostComplaint> createState() => _PostComplaintState();
}

class _PostComplaintState extends State<PostComplaint> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      List<Map<String, dynamic>> responseList = [];
      for (var item in response) {
        if (item['product_id'] == null && item['shop_id'] == null) {
          responseList.add(item);
        }
      }

      // Use where to filter and toList() to create a new list
     
      
      setState(() {
        complaints = responseList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching complaints: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading complaints: ${e.toString()}')),
      );
    }
  }

  Future<void> submitComplaint() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a complaint.')),
      );
      return;
    }

    if (_titleController.text.isEmpty || _complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both a title and complaint description.')),
      );
      return;
    }

    try {
      await supabase.from('tbl_complaint').insert({
        'complaint_title': _titleController.text,
        'complaint_content': _complaintController.text,
        'user_id': userId,
      });

      // Clear the text fields
      _titleController.clear();
      _complaintController.clear();
      
      // Close the dialog
      Navigator.of(context).pop();
      
      // Refresh the complaints list
      fetchComplaints();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your complaint has been submitted!')),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showComplaintDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Submit a Complaint',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Add Complaint Title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Complaint Description',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _complaintController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your complaint...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                _complaintController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteComplaint(int id) async {
    try {
      await supabase.from('tbl_complaint').delete().eq('id', id);
      fetchComplaints();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting complaint: ${e.toString()}')),
      );
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
          "My Complaints",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showComplaintDialog,
        icon: const Icon(Icons.add),
        label: Text(
          'New Complaint',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No complaints submitted yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint['complaint_title'] ?? 'No Title',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              complaint['complaint_content'] ?? 'No Content',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Status Container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: complaint['complaint_status'] != 0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status Row
                                  Row(
                                    children: [
                                      Icon(
                                        complaint['complaint_status'] == 0
                                            ? Icons.hourglass_empty
                                            : Icons.check_circle,
                                        size: 20,
                                        color: complaint['complaint_status'] == 0
                                            ? Colors.grey[600]
                                            : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        complaint['complaint_status'] == 0
                                            ? 'Pending'
                                            : 'Resolved',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: complaint['complaint_status'] == 0
                                              ? Colors.grey[600]
                                              : Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Admin Reply Section
                                  if (complaint['complaint_status'] != 0 && 
                                      complaint['complaint_reply'] != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        Divider(
                                          color: Colors.grey[300],
                                          height: 1,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Admin Reply:',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          complaint['complaint_reply'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            // Timestamp
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Submitted on ${_formatDate(complaint['created_at'])}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}

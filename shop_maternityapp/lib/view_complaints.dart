import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_maternityapp/shop_complaints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  late Future<List<Map<String, dynamic>>> _complaintsFuture;
  final SupabaseClient supabase = Supabase.instance.client;
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _fetchComplaints();
  }

  Future<List<Map<String, dynamic>>> _fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('''
            complaint_id,
            created_at,
            complaint_title,
            complaint_content,
            complaint_status,
            complaint_reply,
            tbl_user!inner(user_name, user_email, user_contact),
            tbl_product!inner(product_id, product_name, shop_id)
          ''')
          .eq('tbl_product.shop_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return (response as List).map((complaint) {
        return {
          'id': complaint['complaint_id'].toString(),
          'customerName': complaint['tbl_user']['user_name'],
          'subject': complaint['complaint_title'],
          'message': complaint['complaint_content'],
          'date': complaint['created_at'].toString().split(' ')[0],
          'status': _mapStatus(complaint['complaint_status']),
          'reply': complaint['complaint_reply'] ?? '',
          'priority': 'Medium',
          'email': complaint['tbl_user']['user_email'],
          'phone': complaint['tbl_user']['user_contact'],
          'orderNumber': 'PROD-${complaint['tbl_product']['product_id']}',
        };
      }).toList();
    } catch (e) {
      print('Error fetching complaints: $e');
      return [];
    }
  }

  String _mapStatus(int status) {
    switch (status) {
      case 0:
        return 'New';
      case 1:
        return 'In Progress';
      case 2:
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }

  List<Map<String, dynamic>> _filterComplaints(
      List<Map<String, dynamic>> complaints) {
    return complaints.where((complaint) {
      final matchesSearch = complaint['customerName']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          complaint['subject']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          complaint['message']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _statusFilter == 'All' || complaint['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Customer Complaints",
                  style: GoogleFonts.sanchez(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopComplaintsPage()),
                    );
                  },
                  icon: Icon(Icons.feedback_outlined),
                  label: Text("Site Feedback"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 198, 176, 249),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search complaints...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      items: ['All', 'New', 'In Progress', 'Resolved']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                        });
                      },
                      hint: const Text("Status"),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _complaintsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading complaints"));
                }
                final complaints = snapshot.data ?? [];
                final filteredComplaints = _filterComplaints(complaints);

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: "Total Complaints",
                            value: complaints.length.toString(),
                            icon: Icons.comment,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            title: "New",
                            value: complaints
                                .where((c) => c['status'] == 'New')
                                .length
                                .toString(),
                            icon: Icons.fiber_new,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            title: "Resolved",
                            value: complaints
                                .where((c) => c['status'] == 'Resolved')
                                .length
                                .toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    filteredComplaints.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No complaints found",
                                  style: GoogleFonts.sanchez(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredComplaints.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final complaint = filteredComplaints[index];
                              return _buildComplaintCard(complaint);
                            },
                          ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.sanchez(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    Color statusColor;
    switch (complaint['status']) {
      case 'New':
        statusColor = Colors.red;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Resolved':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        childrenPadding: const EdgeInsets.all(20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['subject'],
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "From: ${complaint['customerName']}",
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                complaint['status'],
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                complaint['date'],
                style: GoogleFonts.sanchez(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.shopping_bag, size: 14, color: Colors.grey),
            ],
          ),
        ),
        children: [
          const Divider(),
          Text(
            "Message:",
            style: GoogleFonts.sanchez(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            complaint['message'],
            style: GoogleFonts.sanchez(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          if (complaint['reply'] != null && complaint['reply'].isNotEmpty) ...[
            const Divider(),
            Text(
              "Reply:",
              style: GoogleFonts.sanchez(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              complaint['reply'],
              style: GoogleFonts.sanchez(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 15),
          ],
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                complaint['email'],
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                complaint['phone'],
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _showReplyDialog(context, complaint);
            },
            icon: const Icon(Icons.reply, size: 16),
            label: const Text("Reply"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 198, 176, 249),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateComplaint(String id, String reply, int newStatus) async {
    try {
      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': newStatus,
        'complaint_replydate': DateTime.now().toIso8601String(),
      }).eq('complaint_id', id);
      setState(() {
        _complaintsFuture = _fetchComplaints();
      });
    } catch (e) {
      print('Error updating complaint: $e');
    }
  }

  void _showReplyDialog(BuildContext context, Map<String, dynamic> complaint) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reply to ${complaint['customerName']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subject: ${complaint['subject']}",
              style: GoogleFonts.sanchez(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                labelText: "Your Reply",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.isNotEmpty) {
                int newStatus = complaint['status'] == 'New' ? 1 : 2;
                await _updateComplaint(
                    complaint['id'], replyController.text, newStatus);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Reply sent to ${complaint['customerName']}"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 198, 176, 249),
              foregroundColor: Colors.white,
            ),
            child: const Text("Send Reply"),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '1',
      'customerName': 'Emma Johnson',
      'subject': 'Product Quality Issue',
      'message': 'The maternity dress I purchased has a tear in the seam. I would like a replacement or refund.',
      'date': '2025-03-01',
      'status': 'New',
      'priority': 'High',
      'email': 'emma.j@example.com',
      'phone': '+1 (555) 123-4567',
      'orderNumber': 'ORD-2025-001',
    },
    {
      'id': '2',
      'customerName': 'Sophia Williams',
      'subject': 'Late Delivery',
      'message': 'My order was supposed to arrive on February 25th but I still haven\'t received it. Please provide an update.',
      'date': '2025-02-28',
      'status': 'In Progress',
      'priority': 'Medium',
      'email': 'sophia.w@example.com',
      'phone': '+1 (555) 234-5678',
      'orderNumber': 'ORD-2025-042',
    },
    {
      'id': '3',
      'customerName': 'Olivia Brown',
      'subject': 'Wrong Size Delivered',
      'message': 'I ordered a medium maternity support belt but received a small one. I need the correct size as soon as possible.',
      'date': '2025-02-26',
      'status': 'Resolved',
      'priority': 'Medium',
      'email': 'olivia.b@example.com',
      'phone': '+1 (555) 345-6789',
      'orderNumber': 'ORD-2025-036',
    },
    {
      'id': '4',
      'customerName': 'Ava Miller',
      'subject': 'Billing Issue',
      'message': 'I was charged twice for my recent order. Please refund the duplicate charge.',
      'date': '2025-02-25',
      'status': 'New',
      'priority': 'High',
      'email': 'ava.m@example.com',
      'phone': '+1 (555) 456-7890',
      'orderNumber': 'ORD-2025-029',
    },
  ];
  
  String _searchQuery = '';
  String _statusFilter = 'All';
  
  List<Map<String, dynamic>> get _filteredComplaints {
    return _complaints.where((complaint) {
      final matchesSearch = complaint['customerName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          complaint['subject'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          complaint['message'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || complaint['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 250),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Customer Complaints",
              style: GoogleFonts.sanchez(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            
            // Search and Filter
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
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                      hint: Text("Status"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Total Complaints",
                    value: _complaints.length.toString(),
                    icon: Icons.comment,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    title: "New",
                    value: _complaints.where((c) => c['status'] == 'New').length.toString(),
                    icon: Icons.fiber_new,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    title: "In Progress",
                    value: _complaints.where((c) => c['status'] == 'In Progress').length.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    title: "Resolved",
                    value: _complaints.where((c) => c['status'] == 'Resolved').length.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Complaints List
            Expanded(
              child: _filteredComplaints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 10),
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
                      itemCount: _filteredComplaints.length,
                      separatorBuilder: (context, index) => SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final complaint = _filteredComplaints[index];
                        return _buildComplaintCard(complaint);
                      },
                    ),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
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
          SizedBox(width: 15),
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
              SizedBox(height: 5),
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
    
    Color priorityColor;
    switch (complaint['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        childrenPadding: EdgeInsets.all(20),
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
                  SizedBox(height: 5),
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              SizedBox(width: 5),
              Text(
                complaint['date'],
                style: GoogleFonts.sanchez(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 15),
              Icon(Icons.flag, size: 14, color: priorityColor),
              SizedBox(width: 5),
              Text(
                "${complaint['priority']} Priority",
                style: GoogleFonts.sanchez(
                  fontSize: 12,
                  color: priorityColor,
                ),
              ),
              SizedBox(width: 15),
              Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
              SizedBox(width: 5),
              Text(
                complaint['orderNumber'],
                style: GoogleFonts.sanchez(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        children: [
          Divider(),
          Text(
            "Message:",
            style: GoogleFonts.sanchez(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            complaint['message'],
            style: GoogleFonts.sanchez(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.email, size: 16, color: Colors.grey[600]),
              SizedBox(width: 5),
              Text(
                complaint['email'],
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 15),
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              SizedBox(width: 5),
              Text(
                complaint['phone'],
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (complaint['status'] != 'Resolved') ...[
                OutlinedButton.icon(
                  onPressed: () {
                    _updateComplaintStatus(complaint['id'], 'In Progress');
                  },
                  icon: Icon(Icons.pending_actions, size: 16),
                  label: Text("Mark In Progress"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                ),
                SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    _updateComplaintStatus(complaint['id'], 'Resolved');
                  },
                  icon: Icon(Icons.check_circle, size: 16),
                  label: Text("Mark Resolved"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                ),
              ],
              if (complaint['status'] == 'Resolved') ...[
                OutlinedButton.icon(
                  onPressed: () {
                    _updateComplaintStatus(complaint['id'], 'New');
                  },
                  icon: Icon(Icons.refresh, size: 16),
                  label: Text("Reopen"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                ),
              ],
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _showReplyDialog(context, complaint);
                },
                icon: Icon(Icons.reply, size: 16),
                label: Text("Reply"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 198, 176, 249),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _updateComplaintStatus(String id, String newStatus) {
    setState(() {
      final index = _complaints.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        _complaints[index]['status'] = newStatus;
      }
    });
  }
  
  void _showReplyDialog(BuildContext context, Map<String, dynamic> complaint) {
    final _replyController = TextEditingController();
    
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
            SizedBox(height: 15),
            TextField(
              controller: _replyController,
              decoration: InputDecoration(
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
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Reply logic would go here
              if (_replyController.text.isNotEmpty) {
                // In a real app, this would send an email or notification
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Reply sent to ${complaint['customerName']}"),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Update status to In Progress if it's New
                if (complaint['status'] == 'New') {
                  _updateComplaintStatus(complaint['id'], 'In Progress');
                }
                
                Navigator.pop(context);
              }
            },
            child: Text("Send Reply"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 198, 176, 249),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
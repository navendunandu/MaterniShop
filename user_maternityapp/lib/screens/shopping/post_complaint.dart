import 'package:flutter/material.dart';
import 'package:user_maternityapp/main.dart';

class ComplaintPage extends StatefulWidget {
  final int id;

  const ComplaintPage(
      {super.key, required this.id});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  Future<void> submitReviewAndComplaint() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a  complaint.')),
      );
      return;
    }

    if ((_titleController.text.isEmpty && _complaintController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a  complaint.')),
      );
      return;
    }

    try {
      // Insert review if provided
      if (_titleController.text.isNotEmpty) {
        await supabase.from('tbl_complaint').insert({
          'complaint_title': _titleController.text,
          'complaint_content': _complaintController.text,
          'user_id': userId,
          'product_id': widget.id,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your complaint has been submitted!')),
      );

      // Clear the fields
      _titleController.clear();
      _complaintController.clear();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Complaints'),backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add Complaint Title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Write a Complaint:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _complaintController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your complaint...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: submitReviewAndComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 2, 0, 108), // Dark blue color
                foregroundColor: Colors.white, // Text color
                minimumSize:
                    const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
              ),
              child: const Text(
                'Submit Report',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Matching text size
                ),
              ),
            ),

            const SizedBox(height: 20),
            // You can also add any additional UI elements, like a status or info section
          ],
        ),
      ),
    );
  }
}
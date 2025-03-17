import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';

class ManageDietplan extends StatefulWidget {
  const ManageDietplan({super.key});

  @override
  State<ManageDietplan> createState() => _ManageDietplanState();
}

class _ManageDietplanState extends State<ManageDietplan> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  String? selectedTrimester;
  void insert() async {
    try {
      await supabase.from("tbl_dietplan").insert({
        'dietplan_title': _titleController.text,
        'dietplan_description': _descriptionController.text,
        'dietplan_breakfast': _breakfastController.text,
        'dietplan_lunch': _lunchController.text,
        'dietplan_dinner': _dinnerController.text,
        'dietplan_month': selectedTrimester,
      });
      _titleController.clear();
      _descriptionController.clear();
      _breakfastController.clear();
      _lunchController.clear();
      _dinnerController.clear();
      _monthController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dietplan Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error Inserting Dietplan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Add New Dietplan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 10),

          buildInputField("Title", _titleController),
          buildInputField("Description", _descriptionController, maxLines: 3),
          buildInputField("Breakfast", _breakfastController,
              keyboardType: TextInputType.text),
          buildInputField("Lunch", _lunchController,
              keyboardType: TextInputType.text),
          buildInputField("Dinner", _dinnerController,
              keyboardType: TextInputType.text),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonFormField(
                value: selectedTrimester,
                decoration: InputDecoration(
                  labelText: "Select Trimester",
                  border: InputBorder.none,
                ),
                items: [
                  DropdownMenuItem(value: "1", child: Text("First Trimester")),
                  DropdownMenuItem(value: "2", child: Text("Second Trimester")),
                  DropdownMenuItem(value: "3", child: Text("Third Trimester")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTrimester = value.toString();
                  });
                }),
          ),

          SizedBox(height: 20),

          // Submit Button
          Center(
            child: ElevatedButton(
              onPressed: insert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade800,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Submit",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Input Field Widget
  Widget buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
      ),
    );
  }
}

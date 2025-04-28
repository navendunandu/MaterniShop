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
  List<Map<String, dynamic>> _dietplans = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDietplans();
  }

  Future<void> fetchDietplans() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from("tbl_dietplan").select();
      setState(() {
        _dietplans = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching dietplans: $e");
    }
  }

  Future<void> insert() async {
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
      selectedTrimester = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dietplan Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      fetchDietplans();
    } catch (e) {
      print("Error Inserting Dietplan: $e");
    }
  }

  Future<void> deleteDietplan(int id) async {
    await supabase.from("tbl_dietplan").delete().eq('dietplan_id', id);
    fetchDietplans();
  }

  void showEditDialog(Map<String, dynamic> dietplan) {
    _titleController.text = dietplan['dietplan_title'] ?? '';
    _descriptionController.text = dietplan['dietplan_description'] ?? '';
    _breakfastController.text = dietplan['dietplan_breakfast'] ?? '';
    _lunchController.text = dietplan['dietplan_lunch'] ?? '';
    _dinnerController.text = dietplan['dietplan_dinner'] ?? '';
    selectedTrimester = dietplan['dietplan_month']?.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Dietplan"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              buildInputField("Title", _titleController),
              buildInputField("Description", _descriptionController, maxLines: 3),
              buildInputField("Breakfast", _breakfastController),
              buildInputField("Lunch", _lunchController),
              buildInputField("Dinner", _dinnerController),
              DropdownButtonFormField(
                value: selectedTrimester,
                decoration: InputDecoration(labelText: "Select Trimester"),
                items: [
                  DropdownMenuItem(value: "1", child: Text("First Trimester")),
                  DropdownMenuItem(value: "2", child: Text("Second Trimester")),
                  DropdownMenuItem(value: "3", child: Text("Third Trimester")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTrimester = value.toString();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await supabase.from("tbl_dietplan").update({
                'dietplan_title': _titleController.text,
                'dietplan_description': _descriptionController.text,
                'dietplan_breakfast': _breakfastController.text,
                'dietplan_lunch': _lunchController.text,
                'dietplan_dinner': _dinnerController.text,
                'dietplan_month': selectedTrimester,
              }).eq('dietplan_id', dietplan['dietplan_id']);
              Navigator.pop(context);
              fetchDietplans();
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
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

          SizedBox(height: 30),
          Text(
            "Dietplan List",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _dietplans.isEmpty
                  ? Text("No dietplans found.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _dietplans.length,
                      itemBuilder: (context, index) {
                        final plan = _dietplans[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(plan['dietplan_title'] ?? ''),
                            subtitle: Text(
                                "Description: ${plan['dietplan_description']}\nBreakfast: ${plan['dietplan_breakfast']}\nLunch: ${plan['dietplan_lunch']}\nDinner: ${plan['dietplan_dinner']}\nTrimester: ${plan['dietplan_month']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Color.fromARGB(255, 160, 141, 247)),
                                  onPressed: () => showEditDialog(plan),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color.fromARGB(255, 160, 141, 247)),
                                  onPressed: () => deleteDietplan(plan['dietplan_id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ManageExercise extends StatefulWidget {
  const ManageExercise({super.key});

  @override
  State<ManageExercise> createState() => _ManageExerciseState();
}

class _ManageExerciseState extends State<ManageExercise> {
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _fileController = TextEditingController();

  PlatformFile? pickedImage;
  String? selectedTrimester;


  void insert() async {
    try {
      String? url = await photoUpload();
      await supabase.from("tbl_exercise").insert({
        'exercise_title': _exerciseController.text,
        'exercise_description': _descriptionController.text,
        'exercise_trimester': selectedTrimester,
        'exercise_file': url,
      });
      _exerciseController.clear();
      _descriptionController.clear();
      _weekController.clear();
      _fileController.clear();
      selectedTrimester = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exercise Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error Inserting Exercise: $e");
    }
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, 
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        _fileController.text = pickedImage!.name;
      });
    }
  }

  Future<String?> photoUpload() async {
    try {
      final bucketName = 'Exercise';
      final now = DateTime.now();
      final timestamp = DateFormat('dd-MM-yy-HH-mm-ss').format(now);
      final fileExtension = pickedImage!.name.split('.').last;
      final fileName = "$timestamp.$fileExtension";

      await supabase.storage.from(bucketName).uploadBinary(
        fileName,
        pickedImage!.bytes!,
      );

      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
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
            "Add New Exercise",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 10),

          // Exercise Title
          buildInputField("Title", _exerciseController),

          // Description
          buildInputField("Description", _descriptionController, maxLines: 3),

          // Week Number
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

          // File Upload
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pickedImage != null ? pickedImage!.name : "Upload File",
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.upload_file, color: Colors.purple.shade800),
                  onPressed: handleImagePick,
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Submit Button
          Center(
            child: ElevatedButton(
              onPressed: (){
                insert();
              },
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

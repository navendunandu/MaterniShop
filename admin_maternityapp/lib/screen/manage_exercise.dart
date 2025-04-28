import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

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

  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from("tbl_exercise").select();
      setState(() {
        _exercises = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching exercises: $e");
    }
  }

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
      pickedImage = null;
      selectedTrimester = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exercise Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      fetchExercises();
    } catch (e) {
      print("Error Inserting Exercise: $e");
    }
  }

  Future<void> deleteExercise(int id) async {
    await supabase.from("tbl_exercise").delete().eq('exercise_id', id);
    fetchExercises();
  }

  void showEditDialog(Map<String, dynamic> exercise) {
    _exerciseController.text = exercise['exercise_title'] ?? '';
    _descriptionController.text = exercise['exercise_description'] ?? '';
    selectedTrimester = exercise['exercise_trimester']?.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Exercise"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              buildInputField("Title", _exerciseController),
              buildInputField("Description", _descriptionController, maxLines: 3),
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
              await supabase.from("tbl_exercise").update({
                'exercise_title': _exerciseController.text,
                'exercise_description': _descriptionController.text,
                'exercise_trimester': selectedTrimester,
              }).eq('exercise_id', exercise['exercise_id']);
              Navigator.pop(context);
              fetchExercises();
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, 
      type: FileType.video,
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
      if (pickedImage == null) return null;
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

          // Trimester Dropdown
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
                    pickedImage != null ? pickedImage!.name : "Upload Video",
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
            "Exercise List",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _exercises.isEmpty
                  ? Text("No exercises found.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _exercises[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(exercise['exercise_title'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Description: ${exercise['exercise_description'] ?? ''}"),
                                Text("Trimester: ${exercise['exercise_trimester'] ?? ''}"),
                                if (exercise['exercise_file'] != null && exercise['exercise_file'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SizedBox(
                                    height: 500, 
                                   width: double.infinity,
                                    child: ExerciseVideoPlayer(url: exercise['exercise_file']),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Color.fromARGB(255, 160, 141, 247)),
                                  onPressed: () => showEditDialog(exercise),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color.fromARGB(255, 160, 141, 247)),
                                  onPressed: () => deleteExercise(exercise['exercise_id']),
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

// Widget to display video using video_player package (supports web)
class ExerciseVideoPlayer extends StatefulWidget {
  final String url;
  const ExerciseVideoPlayer({super.key, required this.url});

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 48,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

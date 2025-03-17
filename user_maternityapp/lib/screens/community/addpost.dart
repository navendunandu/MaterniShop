import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:user_maternityapp/main.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _contentController = TextEditingController();
  bool isSubmitting = false;
  String? errorMessage;
  bool _showImageOptions = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _showImageOptions = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image. Please try again.')),
      );
    }
  }

  void _showImageSourceOptions() {
    setState(() {
      _showImageOptions = true;
    });
  }

  Future<String?> _uploadImage() async {
    try {
      if (_image == null) return null;

      // Get current date and time
      String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm-ss').format(DateTime.now());

      // Extract file extension
      String fileExtension = path.extension(_image!.path);

      // Generate filename with extension
      String fileName = 'post-$formattedDate$fileExtension';

      // Upload image
      await supabase.storage.from('Post').upload(fileName, _image!);

      // Get public URL of the uploaded image
      final imageUrl = supabase.storage.from('Post').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      throw e; // Rethrow to handle in calling function
    }
  }

  Future<void> _createPost() async {
    // Validate input
    if (_contentController.text.trim().isEmpty && _image == null) {
      setState(() {
        errorMessage = 'Please add some text or an image to your post';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      String? imageUrl;

      // Upload image if selected
      if (_image != null) {
        imageUrl = await _uploadImage();
      }

      // Insert post
      await supabase.from('tbl_post').insert({
        'post_content': _contentController.text.trim(),
        'post_file': imageUrl,
        'post_datetime': DateTime.now().toIso8601String(),
        'user_id': supabase.auth.currentUser!.id,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Post created successfully!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = 'Failed to create post. Please try again.';
      });
      print("Error creating post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        title: Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: isSubmitting ? null : _createPost,
            child: isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.blue[400],
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blue[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_showImageOptions) {
            setState(() {
              _showImageOptions = false;
            });
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue[100],
                          child: Icon(
                            Icons.person,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share with the community',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Your post will be visible to all members',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Post content
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 18,
                        ),
                      ),
                      maxLines: 10,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Image preview
                    if (_image != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Error message
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 14,
                          ),
                        ),
                      ),

                    SizedBox(height: 100), // Space for bottom actions
                  ],
                ),
              ),
            ),

            // Bottom actions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Add to your post:',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.photo,
                        color: Colors.green[600],
                        size: 28,
                      ),
                      onPressed: _showImageSourceOptions,
                    ),
                  ],
                ),
              ),
            ),

            // Image source options
            if (_showImageOptions)
              Positioned(
                bottom: 70,
                left: 16,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library,
                            color: Colors.purple[400]),
                        title: Text('Gallery'),
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading:
                            Icon(Icons.camera_alt, color: Colors.blue[400]),
                        title: Text('Camera'),
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

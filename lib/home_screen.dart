import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final SupabaseClient client;

  const HomePage({super.key, required this.client});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _instagramController = TextEditingController();
  File? _selectedVideo;
  final _picker = ImagePicker();
  late AnimationController _animationController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _pickVideo() async {
    try {
      XFile? pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
      setState(() {
        _selectedVideo = pickedVideo != null ? File(pickedVideo.path) : null;
      });
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) {
      // Show an error message, video is not selected
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final supabase = widget.client;
    final phoneNumber = _phoneNumberController.text.trim();
    final fileName = '$phoneNumber.mp4';

    try {
      // Upload video to Supabase Storage
      final storageResponse = await supabase.storage
          .from('review')
          .uploadBinary(
        fileName,
        await _selectedVideo!.readAsBytes(),
      );

      // Video uploaded successfully, get the URL
      final videoUrl = supabase.storage.from('review').getPublicUrl(fileName);

      // Insert user information into Supabase table
      final response = await supabase.from('data').upsert([
        {
          'name': _nameController.text.trim(),
          'phone_number': _phoneNumberController.text.trim(),
          'instagram_username': _instagramController.text.trim(),
          'video_url': videoUrl.toString(),
        }
      ]);

      _animationController.forward().whenComplete(() {
        setState(() {
          _isUploading = false;
        });
        _animationController.reverse(); // Reset the animation for future use
        // You can navigate to another screen or perform additional actions here
      });
    } catch (e) {
      // Handle the error (e.g., show a snackbar)
      print('Error uploading video: $e');
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(child: Text('Love Shots')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 180,
                ),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _instagramController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Instagram username';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Instagram Username',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      _pickVideo();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                  ),
                  child: const Text('Select Video'),
                ),
                if (_selectedVideo == null)
                  const Text(
                    'Please select a video',
                    style: TextStyle(color: Colors.red),
                  ),
                if (_selectedVideo != null)
                  Text('Selected Video: ${_selectedVideo!.uri}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () {
                    if (_selectedVideo != null) {
                      _uploadVideo();
                    } else {
                      // Show an error message, video is not selected
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isUploading
                        ? Colors.grey
                        : (_selectedVideo != null ? Colors.cyan : Colors.grey),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
                // Animated checkmark
                FadeTransition(
                  opacity: _animationController,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

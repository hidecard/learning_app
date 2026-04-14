import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/validation_helper.dart';

class CourseVideoForm extends StatefulWidget {
  final Map<String, dynamic>? courseData;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const CourseVideoForm({
    super.key,
    this.courseData,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<CourseVideoForm> createState() => _CourseVideoFormState();
}

class _CourseVideoFormState extends State<CourseVideoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseNameController;
  late TextEditingController _videoTitleController;
  late TextEditingController _youtubeUrlController;
  late TextEditingController _categoryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.courseData?['course_name'] ?? '');
    _videoTitleController = TextEditingController(text: widget.courseData?['video_title'] ?? '');
    _youtubeUrlController = TextEditingController(text: widget.courseData?['youtube_url'] ?? '');
    _categoryController = TextEditingController(text: widget.courseData?['category'] ?? '');
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _videoTitleController.dispose();
    _youtubeUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveCourseVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final courseData = {
        'course_name': _courseNameController.text.trim(),
        'video_title': _videoTitleController.text.trim(),
        'youtube_url': _youtubeUrlController.text.trim(),
        'category': _categoryController.text.trim(),
        'row': widget.courseData?['row'],
      };

      await widget.onSave(courseData);
      Get.back();
      Get.snackbar(
        'Success',
        widget.courseData == null ? 'Course video created successfully' : 'Course video updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save course video: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.courseData == null ? 'Add Course Video' : 'Edit Course Video',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C4852),
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _courseNameController,
                        decoration: InputDecoration(
                          labelText: 'Course Name',
                          hintText: 'Enter course name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                          ),
                        ),
                        validator: (value) => ValidationHelper.validateRequired(value, 'course name'),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _videoTitleController,
                        decoration: InputDecoration(
                          labelText: 'Video Title',
                          hintText: 'Enter video title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                          ),
                        ),
                        validator: (value) => ValidationHelper.validateRequired(value, 'video title'),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _youtubeUrlController,
                        decoration: InputDecoration(
                          labelText: 'YouTube URL',
                          hintText: 'Enter YouTube video URL',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                          ),
                          helperText: 'Supported formats: youtube.com/watch?v=ID, youtu.be/ID, youtube.com/embed/ID',
                        ),
                        validator: ValidationHelper.validateYouTubeUrl,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'Enter video category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                          ),
                        ),
                        validator: (value) => ValidationHelper.validateRequired(value, 'category'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF00C2FF)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF00C2FF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCourseVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/activation_service.dart';
import '../../data/services/admin_auth_service.dart';
import '../../data/services/sheets_service.dart';
import '../../data/models/activation_key_model.dart';
import '../../data/models/blog_model.dart';
import '../widgets/activation_key_card.dart';
import '../widgets/blog_form.dart';
import '../widgets/blog_card.dart';
import '../widgets/course_form.dart';
import '../widgets/course_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  final ActivationService _activationService = ActivationService();
  final TextEditingController _keyController = TextEditingController();
  List<ActivationKeyModel> availableKeys = [];
  List<ActivationKeyModel> usedKeys = [];
  List<BlogModel> blogs = [];
  List<Map<String, dynamic>> courses = [];
  bool isLoading = false;
  bool isBlogsLoading = false;
  bool isCoursesLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    if (!await _checkAdminAccess() || !mounted) return;
    await Future.wait([_loadKeys(), _loadBlogs(), _loadCourses()]);
  }

  Future<bool> _checkAdminAccess() async {
    final isAdmin = await AdminAuthService.checkAdminAccess();
    if (isAdmin || !mounted) return isAdmin;

    Get.snackbar(
      'Access Denied',
      AdminAuthService.unauthorizedMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    Get.back();
    return false;
  }

  Future<void> _loadKeys() async {
    if (mounted) setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        _activationService.getAvailableKeys(),
        _activationService.getUsedKeys(),
      ]);
      if (!mounted) return;
      setState(() {
        availableKeys = results[0];
        usedKeys = results[1];
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load activation keys. Please try again.',
      );
    }
  }

  Future<void> _loadBlogs() async {
    if (mounted) setState(() => isBlogsLoading = true);

    try {
      final blogsData = await SheetsService.fetchBlogs();
      if (!mounted) return;
      setState(() {
        blogs = blogsData;
        isBlogsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isBlogsLoading = false);
      Get.snackbar('Error', 'Failed to load blogs. Please try again.');
    }
  }

  Future<void> _createKey() async {
    if (_keyController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a key');
      return;
    }

    try {
      await _activationService.createKey(_keyController.text.trim());
      if (!mounted) return;
      _keyController.clear();
      await _loadKeys();
      Get.snackbar('Success', 'Key created successfully');
    } catch (_) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to create key. Please try again.');
      }
    }
  }

  Future<void> _saveBlog(BlogModel blog) async {
    try {
      Map<String, dynamic> result;

      if (blogs.any((b) => b.id == blog.id)) {
        // Update existing blog
        result = await SheetsService.updateBlog(blog);
      } else {
        // Create new blog
        result = await SheetsService.createBlog(blog);
      }

      if (result['success'] == true) {
        await _loadBlogs();
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deleteBlog(String blogId) async {
    try {
      final result = await SheetsService.deleteBlog(blogId);

      if (result['success'] == true) {
        await _loadBlogs();
        Get.snackbar(
          'Success',
          'Blog deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete blog: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showBlogForm({BlogModel? blog}) {
    Get.dialog(
      BlogForm(blog: blog, onSave: _saveBlog, onCancel: () => Get.back()),
    );
  }

  Future<void> _loadCourses() async {
    if (mounted) setState(() => isCoursesLoading = true);

    try {
      final coursesData = await SheetsService.fetchCoursesRaw();
      if (!mounted) return;
      setState(() {
        courses = coursesData;
        isCoursesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isCoursesLoading = false);
      Get.snackbar('Error', 'Failed to load courses. Please try again.');
    }
  }

  Future<void> _saveCourseVideo(Map<String, dynamic> courseData) async {
    try {
      Map<String, dynamic> result;

      if (courseData['row'] != null) {
        // Update existing course video
        result = await SheetsService.updateCourseVideo(
          row: courseData['row'],
          courseName: courseData['course_name'],
          videoTitle: courseData['video_title'],
          youtubeUrl: courseData['youtube_url'],
          category: courseData['category'],
        );
      } else {
        // Create new course video
        result = await SheetsService.createCourseVideo(
          courseName: courseData['course_name'],
          videoTitle: courseData['video_title'],
          youtubeUrl: courseData['youtube_url'],
          category: courseData['category'],
        );
      }

      if (result['success'] == true) {
        await _loadCourses();
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deleteCourseVideo(int row) async {
    try {
      final result = await SheetsService.deleteCourseVideo(row);

      if (result['success'] == true) {
        await _loadCourses();
        Get.snackbar(
          'Success',
          'Course video deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete course video: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showCourseForm({Map<String, dynamic>? courseData}) {
    Get.dialog(
      CourseVideoForm(
        courseData: courseData,
        onSave: _saveCourseVideo,
        onCancel: () => Get.back(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B0F10),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xFF0B0F10).withValues(alpha: 0.6),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Blogs'),
            Tab(text: 'Courses'),
            Tab(text: 'Keys'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBlogsTab(), _buildCoursesTab(), _buildKeysTab()],
      ),
    );
  }

  Widget _buildBlogsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'Blog Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B0F10),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showBlogForm(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Blog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isBlogsLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : blogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No blogs found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first blog to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showBlogForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Blog'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBlogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: blogs.length,
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      return BlogCard(
                        blog: blog,
                        onEdit: () => _showBlogForm(blog: blog),
                        onDelete: () => _deleteBlog(blog.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCoursesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'Course Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B0F10),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCourseForm(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isCoursesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No course videos found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first course video to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCourseForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CourseVideoCard(
                        courseData: course,
                        onEdit: () => _showCourseForm(courseData: course),
                        onDelete: () => _deleteCourseVideo(course['row']),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildKeysTab() {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Create Key Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Activation Key',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B0F10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _keyController,
                        decoration: InputDecoration(
                          hintText: 'Enter key code (e.g., ABC-123)',
                          hintStyle: TextStyle(
                            color: Color(
                              0xFF0B0F10,
                            ).withValues(alpha: 0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createKey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Key',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Available Keys Section
                _buildKeysSection('Available Keys', availableKeys, false),
                const SizedBox(height: 24),

                // Used Keys Section
                _buildKeysSection('Used Keys', usedKeys, true),
              ],
            ),
          );
  }

  Widget _buildKeysSection(
    String title,
    List<ActivationKeyModel> keys,
    bool isUsedSection,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B0F10),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isUsedSection
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${keys.length}',
                  style: TextStyle(
                    color: isUsedSection ? Colors.red : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (keys.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No ${isUsedSection ? 'used' : 'available'} keys',
                  style: TextStyle(
                    color: Color(0xFF0B0F10).withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                return ActivationKeyCard(
                  activationKey: key,
                  isUsed: isUsedSection,
                  onRefresh: _loadKeys,
                );
              },
            ),
        ],
      ),
    );
  }
}

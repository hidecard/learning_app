import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/sheets_service.dart';
import '../../data/services/blog_service.dart';
import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import 'blog_list.dart';
import 'course_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BlogModel> blogs = [];
  List<CourseModel> courses = [];
  bool isLoading = true;
  String? errorMessage;
  final BlogService _blogService = BlogService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final fetchedBlogs = await SheetsService.fetchBlogs();
      final fetchedCourses = await SheetsService.fetchCourses();
      
      // Update view counts and like counts for blogs from Firebase
      final blogsWithCounts = await Future.wait(
        fetchedBlogs.map((blog) async {
          final viewCount = await _blogService.getViewCount(blog.id);
          final likeCount = await _blogService.getLikeCount(blog.id);
          return blog.copyWith(viewCount: viewCount, likeCount: likeCount);
        })
      );
      
      setState(() {
        blogs = blogsWithCounts;
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Blogs'),
            Tab(icon: Icon(Icons.school), text: 'Courses'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.key), onPressed: () => Get.toNamed('/premium')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    BlogList(blogs: blogs, onRefresh: _loadData),
                    CourseList(courses: courses),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../logic/controllers/auth_controller.dart';
import '../../data/services/sheets_service.dart';
import '../../data/services/blog_service.dart';
import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import 'home_tab.dart';
import 'courses_tab.dart';
import 'blogs_tab.dart';
import 'profile_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
  
  // Static method to access the current instance's tab navigation
  static void navigateToTab(int index) {
    final state = Get.find<_MainNavigationState>();
    state.onTabTapped(index);
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;
  
  // Data for all tabs
  List<BlogModel> blogs = [];
  List<CourseModel> courses = [];
  bool isLoading = true;
  String? errorMessage;
  final BlogService _blogService = BlogService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Get.put<_MainNavigationState>(this); // Register this state for access
    _loadData();
  }

  @override
  void dispose() {
    Get.delete<_MainNavigationState>(); // Clean up the dependency
    _pageController.dispose();
    super.dispose();
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onTabTapped(int index) {
    onTabTapped(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeTab(
            blogs: blogs,
            courses: courses,
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRefresh: _loadData,
          ),
          CoursesTab(
            courses: courses,
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRefresh: _loadData,
          ),
          BlogsTab(
            blogs: blogs,
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRefresh: _loadData,
          ),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  label: 'Courses',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article,
                  label: 'Blogs',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive 
              ? const LinearGradient(
                  colors: [Color(0xFF00C2FF), Color(0xFF007BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive ? [
            BoxShadow(
              color: const Color(0xFF00C2FF).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : const Color(0xFF3C4852).withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : const Color(0xFF3C4852).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

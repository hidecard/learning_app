import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import '../../data/services/blog_service.dart';
import '../../data/services/sheets_service.dart';
import 'blogs_tab.dart';
import 'courses_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  static void navigateToTab(int index) {
    if (Get.isRegistered<_MainNavigationState>()) {
      Get.find<_MainNavigationState>().onTabTapped(index);
    }
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final PageController _pageController;
  List<BlogModel> blogs = const [];
  List<CourseModel> courses = const [];
  bool isLoading = true;
  String? errorMessage;
  final BlogService _blogService = BlogService();
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Get.put<_MainNavigationState>(this);
    _loadData();
  }

  @override
  void dispose() {
    if (Get.isRegistered<_MainNavigationState>()) {
      Get.delete<_MainNavigationState>();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final generation = ++_loadGeneration;
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        SheetsService.fetchBlogs(forceRefresh: true),
        SheetsService.fetchCourses(forceRefresh: true),
      ]);
      final fetchedBlogs = results[0] as List<BlogModel>;
      final fetchedCourses = results[1] as List<CourseModel>;
      final blogsWithCounts = await Future.wait(
        fetchedBlogs.map((blog) async {
          final stats = await _blogService.getStats(blog.id);
          return blog.copyWith(
            viewCount: stats.viewCount,
            likeCount: stats.likeCount,
          );
        }),
      );

      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        blogs = blogsWithCounts;
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        isLoading = false;
        errorMessage = 'We could not load the latest learning content.';
      });
    }
  }

  void onTabTapped(int index) {
    if (index == _currentIndex || !_pageController.hasClients) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (mounted) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
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
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Blogs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

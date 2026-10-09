import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import '../../data/services/blog_service.dart';
import '../../data/services/sheets_service.dart';
import '../widgets/content_shimmer.dart';
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (mounted) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            children: [
              HomeTab(blogs: blogs, courses: courses, isLoading: isLoading, errorMessage: errorMessage, onRefresh: _loadData),
              CoursesTab(courses: courses, isLoading: isLoading, errorMessage: errorMessage, onRefresh: _loadData),
              BlogsTab(blogs: blogs, isLoading: isLoading, errorMessage: errorMessage, onRefresh: _loadData),
              const ProfileTab(),
            ],
          ),
          if (isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: colors.primary.withValues(alpha: .12),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.school_rounded, Icons.school_outlined, 'Courses'),
      (Icons.article_rounded, Icons.article_outlined, 'Blogs'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == _currentIndex;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.$3,
                child: InkWell(
                  onTap: () => onTabTapped(index),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? colors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            selected ? item.$1 : item.$2,
                            key: ValueKey(selected),
                            size: 22,
                            color: selected ? colors.primary : colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? colors.primary : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

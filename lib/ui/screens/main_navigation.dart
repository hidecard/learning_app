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
      bottomNavigationBar: _FloatingBottomNav(
        currentIndex: _currentIndex,
        onSelected: onTabTapped,
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onSelected,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.school_outlined, Icons.school_rounded, 'Courses'),
    (Icons.article_outlined, Icons.article_rounded, 'Blogs'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .55),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .12),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Row(
            children: [
              for (var index = 0; index < _items.length; index++)
                Expanded(child: _item(context, index)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    final selected = currentIndex == index;
    final item = _items[index];
    return Semantics(
      button: true,
      selected: selected,
      label: item.$3,
      child: Tooltip(
        message: item.$3,
        child: InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 54,
            padding: EdgeInsets.symmetric(horizontal: selected ? 13 : 8),
            decoration: BoxDecoration(
              color: selected ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.$2 : item.$1,
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  size: 22,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: selected
                      ? Row(
                          children: [
                            const SizedBox(width: 7),
                            Text(
                              item.$3,
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

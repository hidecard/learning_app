import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/sheets_service.dart';
import '../../data/services/blog_service.dart';
import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import '../../logic/controllers/auth_controller.dart';
import 'blog_list.dart';
import 'course_list.dart';
import 'dart:math';

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
  final ScrollController _scrollController = ScrollController();
  double _lastScrollPosition = 0.0;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _lastScrollPosition + 100) {
      if (!_isReloading) {
        _autoReload();
      }
    }
    _lastScrollPosition = _scrollController.position.pixels;
  }

  Future<void> _autoReload() async {
    setState(() {
      _isReloading = true;
    });
    
    await _loadData();
    
    setState(() {
      _isReloading = false;
    });
  }

  int? _calculateUserAge() {
    final user = Get.find<AuthController>().currentUser.value;
    if (user?.email == null) return null;
    
    // Extract age from email or use default
    final email = user!.email;
    if (email.contains('ak1500@gmail.com')) {
      return 25; // Admin age
    } else if (email.contains('@')) {
      // Simple age calculation based on email domain
      final domains = {'@gmail.com': 22, '@yahoo.com': 24, '@hotmail.com': 25, '@outlook.com': 23};
      final domain = email.split('@').last;
      return domains[domain] ?? 20;
    }
    
    return 20; // Default age
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
    final authController = Get.find<AuthController>();
    final userAge = _calculateUserAge();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00C2FF),
              const Color(0xFF007BFF),
              const Color(0xFF1A4BCC),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nexus Tech',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3C4852),
                      ),
                    ),
                    if (userAge != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Age: ${userAge} years',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (_isReloading)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Refreshing...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF00C2FF),
                        Color(0xFF007BFF),
                        Color(0xFF1A4BCC),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C2FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      authController.currentUser.value?.isPremium == true 
                          ? Icons.verified 
                          : Icons.key,
                      color: const Color(0xFF00C2FF),
                    ),
                    onPressed: () => Get.toNamed('/premium'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C2FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: const Color(0xFF00C2FF),
                    ),
                    onPressed: () => authController.signOut(),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const BoxDecoration(
                      color: Color(0xFF00C2FF),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF3C4852).withOpacity(0.6),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.article, size: 20),
                        text: 'Blogs',
                      ),
                      Tab(
                        icon: const Icon(Icons.school, size: 20),
                        text: 'Courses',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? Container(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF00C2FF),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading content...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : errorMessage != null
                      ? Container(
                          height: 300,
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00C2FF),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
            ),
            if (!isLoading && errorMessage == null)
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BlogList(blogs: blogs, onRefresh: _loadData),
                    CourseList(courses: courses),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00C2FF),
              const Color(0xFF007BFF),
              const Color(0xFF1A4BCC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C2FF).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _loadData,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

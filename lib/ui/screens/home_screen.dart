import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/sheets_service.dart';
import '../../data/services/blog_service.dart';
import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import '../../logic/controllers/auth_controller.dart';
import 'blog_list.dart';
import 'course_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        SheetsService.fetchBlogs(),
        SheetsService.fetchCourses(),
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

      if (!mounted) return;
      setState(() {
        blogs = blogsWithCounts;
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'We could not load the latest learning content.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: CustomScrollView(
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
                      'CodeNest',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B0F10),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      authController.currentUser.value?.isPremium == true
                          ? Icons.verified
                          : Icons.key,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.toNamed('/premium'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const BoxDecoration(
                      color: Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelColor: Color(0xFF0B0F10),
                    unselectedLabelColor: Color(0xFF68758A),
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
                  ? SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading content...',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.1),
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
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
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _loadData,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}

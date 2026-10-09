import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';
import 'main_navigation.dart';

class HomeTab extends StatefulWidget {
  final List<BlogModel> blogs;
  final List<CourseModel> courses;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const HomeTab({
    super.key,
    required this.blogs,
    required this.courses,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();
  List<CourseModel> _courses = const [];
  List<BlogModel> _blogs = const [];

  @override
  void initState() {
    super.initState();
    _courses = widget.courses;
    _blogs = widget.blogs;
    _searchController.addListener(_filterContent);
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courses != widget.courses || oldWidget.blogs != widget.blogs) {
      _filterContent();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContent);
    _searchController.dispose();
    super.dispose();
  }

  void _filterContent() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _courses = query.isEmpty
          ? widget.courses
          : widget.courses
              .where((course) => (course.title ?? '').toLowerCase().contains(query))
              .toList(growable: false);
      _blogs = query.isEmpty
          ? widget.blogs
          : widget.blogs
              .where((blog) => '${blog.title} ${blog.content} ${blog.category}'.toLowerCase().contains(query))
              .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStats(context),
                  const SizedBox(height: 28),
                  _sectionHeader(context, 'Featured courses', 'View all', 1),
                  const SizedBox(height: 14),
                  _buildCourses(context),
                  const SizedBox(height: 28),
                  _sectionHeader(context, 'Fresh from the blog', 'View all', 2),
                  const SizedBox(height: 14),
                  _buildBlogs(context),
                  if (widget.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _buildError(context),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NEXUS TECH', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                SizedBox(height: 3),
                Text('Learn something useful today.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            IconButton(onPressed: widget.onRefresh, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
          ]),
          const SizedBox(height: 24),
          Text('Build your next skill', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Short lessons, practical ideas, real progress.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search courses and articles',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: _searchController.clear, icon: const Icon(Icons.close_rounded)),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(children: [
      _stat(context, Icons.school_outlined, '${widget.courses.length}', 'Courses'),
      const SizedBox(width: 12),
      _stat(context, Icons.article_outlined, '${widget.blogs.length}', 'Articles'),
      const SizedBox(width: 12),
      _stat(context, Icons.play_circle_outline, '${widget.courses.fold<int>(0, (sum, c) => sum + (c.videos?.length ?? 0))}', 'Lessons'),
    ]);
  }

  Widget _stat(BuildContext context, IconData icon, String value, String label) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [Icon(icon, color: colors.primary, size: 21), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 2), Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11))]),
    ));
  }

  Widget _sectionHeader(BuildContext context, String title, String action, int tab) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
    TextButton(onPressed: () => MainNavigation.navigateToTab(tab), child: Text(action)),
  ]);

  Widget _buildCourses(BuildContext context) {
    if (widget.isLoading) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
    if (_courses.isEmpty) return _empty(context, Icons.school_outlined, 'No courses found yet');
    return SizedBox(height: 178, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _courses.take(6).length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final course = _courses[index];
        return SizedBox(width: 230, child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed('/course-detail', arguments: course),
          child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 64, decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.secondaryContainer]), borderRadius: BorderRadius.circular(14)), child: Center(child: Icon(Icons.play_arrow_rounded, size: 34, color: Theme.of(context).colorScheme.primary))),
            const Spacer(),
            Text(course.title?.isNotEmpty == true ? course.title! : 'Untitled course', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text('${course.videos?.length ?? 0} lessons', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          ]))),
        ));
      },
    ));
  }

  Widget _buildBlogs(BuildContext context) {
    if (widget.isLoading) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    if (_blogs.isEmpty) return _empty(context, Icons.article_outlined, 'No articles found yet');
    return Column(children: _blogs.take(3).map((blog) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed('/blog-detail', arguments: blog),
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.lightbulb_outline_rounded)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(blog.category.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)), const SizedBox(height: 5), Text(blog.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text('${blog.viewCount} views  ·  ${blog.likeCount} likes', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11))])),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ])),
      )),
    )).toList());
  }

  Widget _empty(BuildContext context, IconData icon, String text) => SizedBox(height: 110, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Theme.of(context).colorScheme.outline, size: 28), const SizedBox(height: 6), Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))])));

  Widget _buildError(BuildContext context) => Card(color: Theme.of(context).colorScheme.errorContainer, child: ListTile(leading: Icon(Icons.cloud_off_rounded, color: Theme.of(context).colorScheme.onErrorContainer), title: Text(widget.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)), trailing: TextButton(onPressed: widget.onRefresh, child: const Text('Retry'))));
}

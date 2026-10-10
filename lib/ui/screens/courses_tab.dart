import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/course_model.dart';
import '../../data/services/learning_progress_service.dart';

class CoursesTab extends StatefulWidget {
  final List<CourseModel> courses;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  const CoursesTab({
    super.key,
    required this.courses,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });
  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  final _search = TextEditingController();
  final _learning = LearningProgressService();
  String _category = 'All';
  List<String> _categories = ['All'];
  List<CourseModel> _filtered = [];
  final _saved = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _search.addListener(_apply);
    _sync();
  }

  @override
  void didUpdateWidget(covariant CoursesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courses != widget.courses) _sync();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _sync() {
    final values = <String>{'All'};
    for (final course in widget.courses) {
      for (final video in course.videos ?? const <VideoInfo>[]) {
        if (video.category?.isNotEmpty == true) values.add(video.category!);
      }
    }
    _categories = values.toList()..sort();
    _apply();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    for (final course in widget.courses) {
      _saved[_learning.courseKey(course)] = await _learning.isCourseSaved(
        course,
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleSaved(CourseModel course) async {
    final saved = await _learning.toggleCourseSaved(course);
    if (!mounted) return;
    setState(() => _saved[_learning.courseKey(course)] = saved);
    Get.snackbar(
      saved ? 'Saved' : 'Removed',
      saved ? 'Course saved for later.' : 'Course removed from saved items.',
    );
  }

  void _apply() {
    final query = _search.text.trim().toLowerCase();
    final results = widget.courses.where((course) {
      final textMatch = (course.title ?? '').toLowerCase().contains(query);
      final categoryMatch =
          _category == 'All' ||
          (course.videos ?? const <VideoInfo>[]).any(
            (video) => video.category?.toLowerCase() == _category.toLowerCase(),
          );
      return textMatch && categoryMatch;
    }).toList();
    if (mounted) setState(() => _filtered = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Explore and learn',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Find a focused course and start your next lesson.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search courses',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _search.clear,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ChoiceChip(
                  label: Text(_categories[index]),
                  selected: _categories[index] == _category,
                  onSelected: (_) {
                    setState(() => _category = _categories[index]);
                    _apply();
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (widget.isLoading)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (widget.errorMessage != null)
              _error(context)
            else if (_filtered.isEmpty)
              _empty(context)
            else
              ..._filtered.map((course) => _card(context, course)),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, CourseModel course) {
    final colors = Theme.of(context).colorScheme;
    final count = course.videos?.length ?? 0;
    final categories = (course.videos ?? const <VideoInfo>[])
        .map((video) => video.category)
        .whereType<String>()
        .toSet()
        .take(2)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed('/course-detail', arguments: course),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0F10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: colors.primary,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title?.isNotEmpty == true
                            ? course.title!
                            : 'Untitled course',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '$count lessons${categories.isEmpty ? '' : ' · $categories'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'View course →',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleSaved(course),
                  tooltip: _saved[_learning.courseKey(course)] == true
                      ? 'Remove saved course'
                      : 'Save course',
                  icon: Icon(
                    _saved[_learning.courseKey(course)] == true
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _saved[_learning.courseKey(course)] == true
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 80),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            _search.text.isEmpty
                ? 'No courses available'
                : 'No courses match your search',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another keyword or category.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _error(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.cloud_off_rounded),
      title: Text(widget.errorMessage!),
      trailing: TextButton(
        onPressed: widget.onRefresh,
        child: const Text('Retry'),
      ),
    ),
  );
}

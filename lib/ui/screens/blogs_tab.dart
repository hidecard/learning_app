import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/blog_model.dart';
import '../../data/services/blog_service.dart';

class BlogsTab extends StatefulWidget {
  final List<BlogModel> blogs;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  const BlogsTab({
    super.key,
    required this.blogs,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });
  @override
  State<BlogsTab> createState() => _BlogsTabState();
}

class _BlogsTabState extends State<BlogsTab> {
  final _search = TextEditingController();
  final _service = BlogService();
  String _category = 'All';
  List<String> _categories = ['All'];
  List<BlogModel> _filtered = [];
  final _liked = <String, bool>{};
  final _busy = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _search.addListener(_apply);
    _sync();
  }

  @override
  void didUpdateWidget(covariant BlogsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blogs != widget.blogs) _sync();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _sync() {
    final values = <String>{'All'};
    values.addAll(
      widget.blogs
          .map((blog) => blog.category)
          .where((category) => category.trim().isNotEmpty),
    );
    _categories = values.toList()..sort();
    _liked
      ..clear()
      ..addEntries(widget.blogs.map((blog) => MapEntry(blog.id, false)));
    _busy
      ..clear()
      ..addEntries(widget.blogs.map((blog) => MapEntry(blog.id, false)));
    _apply();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final ids = await _service.getLikedBlogIds(
      widget.blogs.map((blog) => blog.id),
    );
    if (!mounted) return;
    setState(() {
      for (final blog in widget.blogs) {
        _liked[blog.id] = ids.contains(blog.id);
      }
    });
  }

  void _apply() {
    final query = _search.text.trim().toLowerCase();
    final results = widget.blogs.where((blog) {
      final textMatch =
          blog.title.toLowerCase().contains(query) ||
          blog.content.toLowerCase().contains(query);
      final categoryMatch =
          _category == 'All' ||
          blog.category.toLowerCase() == _category.toLowerCase();
      return textMatch && categoryMatch;
    }).toList();
    if (mounted) setState(() => _filtered = results);
  }

  Future<void> _like(BlogModel blog) async {
    if (_busy[blog.id] == true) return;
    setState(() => _busy[blog.id] = true);
    try {
      if (!await _service.toggleLike(blog.id)) throw StateError('like failed');
      final stats = await _service.getStats(blog.id);
      final liked = await _service.isLikedByUser(blog.id);
      if (mounted)
        setState(() {
          _liked[blog.id] = liked;
          _filtered = _filtered
              .map(
                (item) => item.id == blog.id
                    ? item.copyWith(
                        viewCount: stats.viewCount,
                        likeCount: stats.likeCount,
                      )
                    : item,
              )
              .toList();
        });
    } catch (_) {
      Get.snackbar('Like not saved', 'Please sign in and try again.');
    }
    if (mounted) setState(() => _busy[blog.id] = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
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
              'Learn beyond the lesson',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Practical ideas, guides and insights for your next project.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search articles',
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
              ..._filtered.map((blog) => _card(context, blog)),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, BlogModel blog) {
    final colors = Theme.of(context).colorScheme;
    final image = blog.imageUrl?.isNotEmpty == true
        ? DecorationImage(
            image: NetworkImage(blog.imageUrl!),
            fit: BoxFit.cover,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed('/blog-detail', arguments: blog),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 78,
                  height: 92,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                    image: image,
                  ),
                  child: image == null
                      ? Icon(
                          Icons.article_outlined,
                          color: colors.primary,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.category.toUpperCase(),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        blog.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        blog.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${blog.viewCount} views',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _like(blog),
                            iconSize: 19,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: _busy[blog.id] == true
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _liked[blog.id] == true
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: _liked[blog.id] == true
                                        ? colors.error
                                        : colors.onSurfaceVariant,
                                  ),
                          ),
                        ],
                      ),
                    ],
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
            Icons.article_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            _search.text.isEmpty
                ? 'No articles available'
                : 'No articles match your search',
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

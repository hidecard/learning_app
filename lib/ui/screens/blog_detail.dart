import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/blog_model.dart';
import '../../data/services/blog_service.dart';
import '../../logic/controllers/learning_state_controller.dart';

class BlogDetail extends StatefulWidget {
  final BlogModel blog;
  const BlogDetail({super.key, required this.blog});
  @override
  State<BlogDetail> createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {
  final _service = BlogService();
  late BlogModel _blog;
  bool _liked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _blog = widget.blog;
    _hydrate();
  }

  Future<void> _hydrate() async {
    final viewed = await _service.updateBlogViewCount(_blog);
    final liked = await _service.isLikedByUser(_blog.id);
    if (!mounted) return;
    setState(() {
      _blog = viewed;
      _liked = liked;
    });
  }

  Future<void> _toggleLike() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (!await _service.toggleLike(_blog.id)) throw StateError('like failed');
      final stats = await _service.getStats(_blog.id);
      final liked = await _service.isLikedByUser(_blog.id);
      if (mounted) {
        setState(() {
          _blog = _blog.copyWith(
            viewCount: stats.viewCount,
            likeCount: stats.likeCount,
          );
          _liked = liked;
        });
      }
    } catch (_) {
      Get.snackbar('Like not saved', 'Please sign in and try again.');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final learning = Get.find<LearningStateController>();
    final readingMinutes = (_blog.content.trim().split(RegExp(r'\s+')).length / 200).ceil().clamp(1, 999);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            onPressed: _toggleLike,
            tooltip: 'Like article',
            icon: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _liked ? colors.error : null,
                  ),
          ),
          Obx(() => IconButton(
            tooltip: learning.isBlogSaved(_blog) ? 'Remove saved article' : 'Save article',
            onPressed: () => learning.toggleBlogSaved(_blog),
            icon: Icon(learning.isBlogSaved(_blog) ? Icons.bookmark : Icons.bookmark_border),
          )),
          IconButton(
            onPressed: () => Get.snackbar(
              'Share',
              'Share link copied when sharing is available.',
            ),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_blog.imageUrl?.isNotEmpty == true)
              Image.network(
                _blog.imageUrl!,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _imageFallback(context),
              )
            else
              _imageFallback(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _meta(context, Icons.sell_outlined, _blog.category),
                      _meta(
                        context,
                        Icons.visibility_outlined,
                        '${_blog.viewCount} views',
                      ),
                      _meta(
                        context,
                        Icons.favorite_border_rounded,
                        '${_blog.likeCount} likes',
                      ),
                      _meta(context, Icons.schedule_outlined, '$readingMinutes min read'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _blog.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(color: colors.outlineVariant),
                  const SizedBox(height: 18),
                  Text(
                    _blog.content,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.75),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      label: Text(_liked ? 'Liked' : 'Like this article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(BuildContext context) => Container(
    height: 190,
    width: double.infinity,
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Icon(
      Icons.article_outlined,
      size: 58,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
  Widget _meta(BuildContext context, IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

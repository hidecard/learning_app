
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/blog_model.dart';
import '../../../data/services/blog_service.dart';

class BlogList extends StatefulWidget {
  final List<BlogModel> blogs;
  final VoidCallback? onRefresh;

  const BlogList({super.key, required this.blogs, this.onRefresh});

  @override
  State<BlogList> createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  final BlogService _blogService = BlogService();
  Map<String, bool> _likedStatus = {};
  Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _checkLikedStatusForBlogs();
  }

  @override
  void didUpdateWidget(BlogList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh like status when blogs list changes (screen reload)
    if (oldWidget.blogs.length != widget.blogs.length || 
        oldWidget.blogs.map((b) => b.id).join(',') != widget.blogs.map((b) => b.id).join(',')) {
      _checkLikedStatusForBlogs();
    }
  }

  Future<void> _checkLikedStatusForBlogs() async {
    for (final blog in widget.blogs) {
      final isLiked = await _blogService.isLikedByUser(blog.id);
      setState(() {
        _likedStatus[blog.id] = isLiked;
      });
    }
  }

  Future<void> _toggleLike(BlogModel blog) async {
    if (_loadingStates[blog.id] == true) return;

    setState(() {
      _loadingStates[blog.id] = true;
    });

    try {
      await _blogService.toggleLike(blog.id);
      final updatedBlog = await _blogService.updateBlogLikeCount(blog);
      final isLiked = await _blogService.isLikedByUser(blog.id);
      
      setState(() {
        _likedStatus[blog.id] = isLiked;
        _loadingStates[blog.id] = false;
      });
    } catch (e) {
      setState(() {
        _loadingStates[blog.id] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.blogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No blogs available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _checkLikedStatusForBlogs();
        widget.onRefresh?.call();
      },
      child: ListView.builder(
        itemCount: widget.blogs.length,
        itemBuilder: (context, index) {
          final blog = widget.blogs[index];
          final isLiked = _likedStatus[blog.id] ?? false;
          final isLoading = _loadingStates[blog.id] ?? false;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: InkWell(
              onTap: () {
                Get.toNamed('/blog-detail', arguments: blog);
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blog image
                  if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        blog.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and category
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                blog.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                blog.category,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Content preview
                        Text(
                          blog.content.length > 150 
                              ? '${blog.content.substring(0, 150)}...' 
                              : blog.content,
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // View count, like count, and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${blog.viewCount} view${blog.viewCount == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Like button
                                InkWell(
                                  onTap: () => _toggleLike(blog),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      isLoading
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                              ),
                                            )
                                          : Icon(
                                              isLiked ? Icons.favorite : Icons.favorite_border,
                                              size: 16,
                                              color: isLiked ? Colors.red : Colors.grey[600],
                                            ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${blog.likeCount} like${blog.likeCount == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Read more',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.deepPurple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

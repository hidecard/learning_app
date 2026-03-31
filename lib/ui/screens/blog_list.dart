
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
      
      // Update the blog in the widget's blog list
      final blogIndex = widget.blogs.indexWhere((b) => b.id == blog.id);
      if (blogIndex != -1) {
        widget.blogs[blogIndex] = updatedBlog;
      }
    } catch (e) {
      setState(() {
        _loadingStates[blog.id] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.blogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C2FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: const Color(0xFF00C2FF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No blogs available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF3C4852),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF3C4852).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _checkLikedStatusForBlogs();
        widget.onRefresh?.call();
      },
      color: const Color(0xFF00C2FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.blogs.length,
        itemBuilder: (context, index) {
          final blog = widget.blogs[index];
          final isLiked = _likedStatus[blog.id] ?? false;
          final isLoading = _loadingStates[blog.id] ?? false;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Get.toNamed('/blog-detail', arguments: blog);
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blog image
                  if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        blog.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF00C2FF).withOpacity(0.1),
                                  const Color(0xFF00C2FF).withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: const Color(0xFF00C2FF).withOpacity(0.5),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF00C2FF),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and category
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                blog.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF3C4852),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C2FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                blog.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF00C2FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Content preview
                        Text(
                          blog.content.length > 150 
                              ? '${blog.content.substring(0, 150)}...' 
                              : blog.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF3C4852).withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // View count, like count, and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.visibility,
                                    size: 16,
                                    color: const Color(0xFF3C4852).withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${blog.viewCount} view${blog.viewCount == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF3C4852).withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Like button
                                GestureDetector(
                                  onTap: () => _toggleLike(blog),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isLiked 
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        isLoading
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    const Color(0xFF00C2FF),
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                isLiked ? Icons.favorite : Icons.favorite_border,
                                                size: 16,
                                                color: isLiked 
                                                    ? Colors.red
                                                    : const Color(0xFF3C4852).withOpacity(0.6),
                                              ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${blog.likeCount} like${blog.likeCount == 1 ? '' : 's'}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: isLiked 
                                                ? Colors.red
                                                : const Color(0xFF3C4852).withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C2FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Read more',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF00C2FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: const Color(0xFF00C2FF),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}

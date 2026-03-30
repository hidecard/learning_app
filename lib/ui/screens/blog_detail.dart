import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/blog_model.dart';
import '../../../data/services/blog_service.dart';

class BlogDetail extends StatefulWidget {
  final BlogModel blog;

  const BlogDetail({super.key, required this.blog});

  @override
  State<BlogDetail> createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {
  final BlogService _blogService = BlogService();
  late BlogModel _currentBlog;
  bool _isViewCountUpdated = false;
  bool _isLiked = false;
  bool _isLoadingLike = false;

  @override
  void initState() {
    super.initState();
    _currentBlog = widget.blog;
    _updateViewCount();
    _checkLikeStatus();
  }

  Future<void> _updateViewCount() async {
    if (!_isViewCountUpdated) {
      final updatedBlog = await _blogService.updateBlogViewCount(_currentBlog);
      setState(() {
        _currentBlog = updatedBlog;
        _isViewCountUpdated = true;
      });
    }
  }

  Future<void> _checkLikeStatus() async {
    final isLiked = await _blogService.isLikedByUser(_currentBlog.id);
    setState(() {
      _isLiked = isLiked;
    });
  }

  Future<void> _toggleLike() async {
    if (_isLoadingLike) return;
    
    setState(() {
      _isLoadingLike = true;
    });

    try {
      await _blogService.toggleLike(_currentBlog.id);
      final updatedBlog = await _blogService.updateBlogLikeCount(_currentBlog);
      final isLiked = await _blogService.isLikedByUser(_currentBlog.id);
      
      setState(() {
        _currentBlog = updatedBlog;
        _isLiked = isLiked;
        _isLoadingLike = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLike = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Detail'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Like button
          IconButton(
            onPressed: _isLoadingLike ? null : _toggleLike,
            icon: _isLoadingLike
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                  ),
          ),
          // View count display
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_currentBlog.viewCount}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog image
            if (_currentBlog.imageUrl != null && _currentBlog.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Image.network(
                  _currentBlog.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
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
            // Blog content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip, view count, and like count
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          _currentBlog.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.deepPurple,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentBlog.viewCount} view${_currentBlog.viewCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: _isLiked ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentBlog.likeCount} like${_currentBlog.likeCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    _currentBlog.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content
                  Text(
                    _currentBlog.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Like button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingLike ? null : _toggleLike,
                      icon: _isLoadingLike
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                            ),
                      label: Text(_isLiked ? 'Liked' : 'Like'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLiked ? Colors.red : Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Like count display
                  Center(
                    child: Text(
                      '${_currentBlog.likeCount} ${_currentBlog.likeCount == 1 ? 'person likes' : 'people like'} this',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Blogs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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
  }
}

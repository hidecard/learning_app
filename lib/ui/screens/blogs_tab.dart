import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../data/models/blog_model.dart';
import 'blog_detail.dart';
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
  final BlogService _blogService = BlogService();
  final TextEditingController _searchController = TextEditingController();
  List<BlogModel> _filteredBlogs = [];
  String _selectedCategory = 'All';
  bool _isSearching = false;
  List<String> _categories = ['All'];
  Map<String, bool> _likedStatus = {};
  Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _filteredBlogs = widget.blogs;
    _searchController.addListener(_onSearchChanged);
    _extractCategoriesFromAPI();
    _initializeLikedStatus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeLikedStatus() {
    for (var blog in widget.blogs) {
      _likedStatus[blog.id] = false;
      _loadingStates[blog.id] = false;
    }
  }

  void _extractCategoriesFromAPI() {
    final Set<String> categorySet = {'All'};
    
    for (final blog in widget.blogs) {
      if (blog.category.isNotEmpty) {
        categorySet.add(blog.category);
      }
    }
    
    setState(() {
      _categories = categorySet.toList();
      _categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _applyCategoryFilter();
      } else {
        _isSearching = true;
        _filteredBlogs = widget.blogs.where((blog) {
          final title = blog.title.toLowerCase();
          final content = blog.content.toLowerCase();
          return title.contains(query) || content.contains(query);
        }).toList();
      }
    });
  }

  void _applyCategoryFilter() {
    if (_selectedCategory == 'All') {
      _filteredBlogs = _isSearching 
          ? widget.blogs.where((blog) {
              final title = blog.title.toLowerCase();
              final content = blog.content.toLowerCase();
              return title.contains(_searchController.text.toLowerCase()) || content.contains(_searchController.text.toLowerCase());
            }).toList()
          : widget.blogs;
    } else {
      _filteredBlogs = widget.blogs.where((blog) {
        final title = blog.title.toLowerCase();
        final content = blog.content.toLowerCase();
        final matchesSearch = _isSearching 
            ? title.contains(_searchController.text.toLowerCase()) || content.contains(_searchController.text.toLowerCase())
            : true;
        final categoryMatch = blog.category.toLowerCase() == _selectedCategory.toLowerCase();
        return matchesSearch && categoryMatch;
      }).toList();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _applyCategoryFilter();
    });
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3C4852),
                ),
              ),
            ),
            const Divider(),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  
                  return ListTile(
                    title: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? const Color(0xFF00C2FF) : const Color(0xFF3C4852),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF00C2FF))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _onCategoryChanged(category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(BlogsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blogs.length != widget.blogs.length || 
        oldWidget.blogs.map((b) => b.id).join(',') != widget.blogs.map((b) => b.id).join(',')) {
      _initializeLikedStatus();
    }
  }

  Future<void> _checkLikedStatusForBlogs() async {
    for (final blog in widget.blogs) {
      final isLiked = await _blogService.isLikedByUser(blog.id);
      final likeCount = await _blogService.getLikeCount(blog.id);
      setState(() {
        _likedStatus[blog.id] = isLiked;
        _loadingStates[blog.id] = false;
      });
      
      // Update the blog in the list with current like count
      final blogIndex = widget.blogs.indexWhere((b) => b.id == blog.id);
      if (blogIndex != -1) {
        widget.blogs[blogIndex] = widget.blogs[blogIndex].copyWith(likeCount: likeCount);
      }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Blogs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C4852),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C2FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Color(0xFF00C2FF),
              ),
              onPressed: () {
                _showCategoryFilter(context);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: const TextStyle(
                  color: Color(0xFF3C4852),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF00C2FF),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xFF00C2FF),
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                color: Color(0xFF3C4852),
                fontSize: 16,
              ),
            ),
          ),
          
          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return GestureDetector(
                  onTap: () => _onCategoryChanged(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [const Color(0xFF00C2FF), const Color(0xFF007BFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected 
                          ? null 
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.transparent 
                            : const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : const Color(0xFF00C2FF),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF3C4852),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Blog List
          Expanded(
            child: widget.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                    ),
                  )
                : widget.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: widget.onRefresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C2FF),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredBlogs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C2FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.article_outlined,
                                    size: 64,
                                    color: Color(0xFF00C2FF),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _isSearching ? 'No blogs found' : 'No blogs available',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C4852),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF3C4852).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              widget.onRefresh();
                            },
                            color: const Color(0xFF00C2FF),
                            child: ListView.builder(
                              itemCount: _filteredBlogs.length,
                              itemBuilder: (context, index) {
                                final blog = _filteredBlogs[index];
                                final isLiked = _likedStatus[blog.id] ?? false;
                                final isLoading = _loadingStates[blog.id] ?? false;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => Get.toNamed('/blog-detail', arguments: blog),
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
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 180,
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
                                                    size: 40,
                                                    color: const Color(0xFF00C2FF).withOpacity(0.5),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  height: 180,
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
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      blog.title,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF3C4852),
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF00C2FF).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.visibility,
                                                          color: Color(0xFF00C2FF),
                                                          size: 14,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${blog.viewCount} view${blog.viewCount == 1 ? '' : 's'}',
                                                          style: const TextStyle(
                                                            color: Color(0xFF00C2FF),
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                blog.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: const Color(0xFF3C4852).withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                blog.content.length > 100 
                                                    ? '${blog.content.substring(0, 100)}...' 
                                                    : blog.content,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: const Color(0xFF3C4852).withOpacity(0.7),
                                                  height: 1.4,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => _toggleLike(blog),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: isLiked ? Colors.red.withOpacity(0.1) : const Color(0xFF00C2FF).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          isLoading
                                                              ? const SizedBox(
                                                                  width: 16,
                                                                  height: 16,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth: 2,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                      Color(0xFF00C2FF),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Icon(
                                                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                                                  color: isLiked ? Colors.red : const Color(0xFF3C4852).withOpacity(0.6),
                                                                  size: 16,
                                                                ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '${blog.likeCount} like${blog.likeCount == 1 ? '' : 's'}',
                                                            style: TextStyle(
                                                              color: isLiked ? Colors.red : const Color(0xFF3C4852).withOpacity(0.6),
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF00C2FF).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.arrow_forward_ios,
                                                          color: Color(0xFF00C2FF),
                                                          size: 14,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        const Text(
                                                          'Read More',
                                                          style: TextStyle(
                                                            color: Color(0xFF00C2FF),
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                          ),
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
                          ),
          ),
        ],
      ),
    );
  }
}

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final int viewCount;
  final int likeCount;

  const BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.viewCount = 0,
    this.likeCount = 0,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    int number(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return BlogModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString().trim() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString().trim() ?? 'General',
      imageUrl: json['image_url']?.toString().trim().isEmpty == true
          ? null
          : json['image_url']?.toString(),
      viewCount: number(json['view_count']),
      likeCount: number(json['like_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'image_url': imageUrl,
    'view_count': viewCount,
    'like_count': likeCount,
  };

  BlogModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    int? viewCount,
    int? likeCount,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}

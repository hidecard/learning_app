class CourseModel {
  final String? id;
  final String? title;
  final List<VideoInfo>? videos;

  CourseModel({
    this.id,
    this.title,
    this.videos,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      videos: (json['videos'] as List<dynamic>?)?.map((v) => VideoInfo.fromJson(v)).toList(),
    );
  }
}

class VideoInfo {
  final String? title;
  final String? youtubeUrl;
  final String? category;

  VideoInfo({
    this.title,
    this.youtubeUrl,
    this.category,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['video_title']?.toString(),
      youtubeUrl: json['youtube_url']?.toString(),
      category: json['category']?.toString(),
    );
  }

  String? get youtubeId {
    if (youtubeUrl == null || youtubeUrl!.isEmpty) return null;
    
    // Extract YouTube ID from URL
    final RegExp regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)');
    final match = regex.firstMatch(youtubeUrl!);
    return match?.group(1);
  }
}

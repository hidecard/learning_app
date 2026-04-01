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
  final String? duration;
  final String? thumbnailUrl;

  VideoInfo({
    this.title,
    this.youtubeUrl,
    this.category,
    this.duration,
    this.thumbnailUrl,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['video_title']?.toString(),
      youtubeUrl: json['youtube_url']?.toString(),
      category: json['category']?.toString(),
      duration: json['duration']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
    );
  }

  String? get youtubeId {
    if (youtubeUrl == null || youtubeUrl!.isEmpty) return null;
    
    // Extract YouTube ID from URL - more comprehensive regex
    final RegExp regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)([^&\n?#]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(youtubeUrl!);
    final id = match?.group(1);
    
    print('Extracting YouTube ID from: $youtubeUrl');
    print('Extracted ID: $id');
    
    return id;
  }

  String? get computedThumbnailUrl {
    final id = youtubeId;
    if (id == null) return null;
    
    // Use high quality thumbnail by default
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  String? get maxThumbnailUrl {
    final id = youtubeId;
    if (id == null) return null;
    
    // Use maximum quality thumbnail
    return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
  }

  String? get displayThumbnailUrl {
    // Return custom thumbnail if available, otherwise use computed YouTube thumbnail
    return thumbnailUrl ?? computedThumbnailUrl;
  }

  String? get durationFormatted {
    if (duration == null || duration!.isEmpty) return null;
    
    // If duration is already in MM:SS or HH:MM:SS format, return as is
    if (duration!.contains(':')) {
      return duration!;
    }
    
    // If duration is in seconds, convert to MM:SS format
    try {
      final seconds = int.parse(duration!);
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return duration;
    }
  }
}

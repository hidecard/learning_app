class CourseModel {
  final String? id;
  final String? title;
  final List<VideoInfo>? videos;

  const CourseModel({this.id, this.title, this.videos});

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawVideos = json['videos'];
    final videos = rawVideos is List
        ? rawVideos
              .whereType<Map>()
              .map(
                (video) => VideoInfo.fromJson(Map<String, dynamic>.from(video)),
              )
              .toList(growable: false)
        : null;

    return CourseModel(
      id: json['id']?.toString(),
      title: json['title']?.toString().trim(),
      videos: videos,
    );
  }
}

class VideoInfo {
  final String? title;
  final String? youtubeUrl;
  final String? category;
  final String? duration;
  final String? thumbnailUrl;

  const VideoInfo({
    this.title,
    this.youtubeUrl,
    this.category,
    this.duration,
    this.thumbnailUrl,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['video_title']?.toString().trim(),
      youtubeUrl: json['youtube_url']?.toString().trim(),
      category: json['category']?.toString().trim(),
      duration: json['duration']?.toString().trim(),
      thumbnailUrl: json['thumbnail_url']?.toString().trim(),
    );
  }

  String? get youtubeId {
    final url = youtubeUrl;
    if (url == null || url.isEmpty) return null;

    final match = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([^&\n?#]+)',
      caseSensitive: false,
    ).firstMatch(url);
    return match?.group(1);
  }

  String? get computedThumbnailUrl {
    final id = youtubeId;
    return id == null ? null : 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  String? get maxThumbnailUrl {
    final id = youtubeId;
    return id == null
        ? null
        : 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
  }

  String? get displayThumbnailUrl =>
      thumbnailUrl?.isNotEmpty == true ? thumbnailUrl : computedThumbnailUrl;

  String? get durationFormatted {
    final value = duration;
    if (value == null || value.isEmpty) return null;
    if (value.contains(':')) return value;

    final seconds = int.tryParse(value);
    if (seconds == null) return value;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

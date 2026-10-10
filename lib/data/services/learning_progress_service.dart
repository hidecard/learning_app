import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';

class LearningProgressService {
  static const _lastLessonKey = 'learning_last_lesson';
  static const _completedKey = 'learning_completed_lessons';
  static const _savedBlogsKey = 'learning_saved_blogs';
  static const _readingProgressKey = 'learning_reading_progress';

  String lessonKey(String? courseTitle, VideoInfo video) {
    final course = (courseTitle ?? 'course').trim().toLowerCase();
    return '$course::${video.youtubeId ?? video.title ?? 'lesson'}';
  }

  Future<void> markStarted(String? courseTitle, VideoInfo video) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLessonKey, lessonKey(courseTitle, video));
  }

  Future<void> markCompleted(String? courseTitle, VideoInfo video) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? <String>[];
    final key = lessonKey(courseTitle, video);
    if (!completed.contains(key)) completed.add(key);
    await prefs.setStringList(_completedKey, completed);
    await prefs.setString(_lastLessonKey, key);
  }

  Future<bool> isCompleted(String? courseTitle, VideoInfo video) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedKey) ?? <String>[]).contains(
      lessonKey(courseTitle, video),
    );
  }

  Future<double> courseProgress(
    String? courseTitle,
    List<VideoInfo> videos,
  ) async {
    if (videos.isEmpty) return 0;
    final completed = await Future.wait(
      videos.map((video) => isCompleted(courseTitle, video)),
    );
    return completed.where((value) => value).length / videos.length;
  }

  Future<String?> lastLessonKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLessonKey);
  }

  Future<bool> isBlogSaved(String blogId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_savedBlogsKey) ?? <String>[]).contains(blogId);
  }

  Future<bool> toggleBlogSaved(String blogId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_savedBlogsKey) ?? <String>[];
    final isSaved = saved.contains(blogId);
    if (isSaved) {
      saved.remove(blogId);
    } else {
      saved.add(blogId);
    }
    await prefs.setStringList(_savedBlogsKey, saved);
    return !isSaved;
  }

  Future<void> saveReadingProgress(String blogId, double value) async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, double>{};
    for (final entry
        in prefs.getStringList(_readingProgressKey) ?? <String>[]) {
      final parts = entry.split('|');
      if (parts.length == 2) values[parts[0]] = double.tryParse(parts[1]) ?? 0;
    }
    values[blogId] = value.clamp(0, 1);
    await prefs.setStringList(
      _readingProgressKey,
      values.entries.map((entry) => '${entry.key}|${entry.value}').toList(),
    );
  }

  Future<double> readingProgress(String blogId) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry
        in prefs.getStringList(_readingProgressKey) ?? <String>[]) {
      final parts = entry.split('|');
      if (parts.length == 2 && parts[0] == blogId) {
        return double.tryParse(parts[1]) ?? 0;
      }
    }
    return 0;
  }
}

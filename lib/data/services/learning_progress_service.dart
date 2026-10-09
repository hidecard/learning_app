import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';

class LearningProgressService {
  static const _lastLessonKey = 'learning_last_lesson';
  static const _completedKey = 'learning_completed_lessons';

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

  Future<String?> lastLessonKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLessonKey);
  }
}

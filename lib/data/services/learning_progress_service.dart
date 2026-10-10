import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';

class LearningProgressService {
  static const _lastLessonKey = 'learning_last_lesson';
  static const _completedKey = 'learning_completed_lessons';
  static const _savedBlogsKey = 'learning_saved_blogs';
  static const _savedCoursesKey = 'learning_saved_courses';
  static const _readingProgressKey = 'learning_reading_progress';
  static const _streakCountKey = 'learning_streak_count';
  static const _streakDateKey = 'learning_streak_date';
  static const _dailyCompletedKey = 'learning_daily_completed';
  static const _dailyDateKey = 'learning_daily_date';
  static const dailyGoal = 1;

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
    final isNewCompletion = !completed.contains(key);
    if (isNewCompletion) completed.add(key);
    await prefs.setStringList(_completedKey, completed);
    await prefs.setString(_lastLessonKey, key);
    if (isNewCompletion) {
      final todayKey = _dateKey(DateTime.now());
      if (prefs.getString(_dailyDateKey) != todayKey) {
        await prefs.setString(_dailyDateKey, todayKey);
        await prefs.setInt(_dailyCompletedKey, 0);
      }
      final dailyCount = prefs.getInt(_dailyCompletedKey) ?? 0;
      await prefs.setInt(_dailyCompletedKey, dailyCount + 1);
    }
  }

  Future<int> dailyCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_dailyDateKey) != _dateKey(DateTime.now())) return 0;
    return prefs.getInt(_dailyCompletedKey) ?? 0;
  }

  Future<int> completedLessonCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedKey) ?? <String>[]).length;
  }

  String _dateKey(DateTime value) => '${value.year}-${value.month}-${value.day}';

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

  String courseKey(CourseModel course) =>
      (course.id ?? course.title ?? 'course').trim().toLowerCase();

  Future<bool> isCourseSaved(CourseModel course) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_savedCoursesKey) ?? <String>[]).contains(
      courseKey(course),
    );
  }

  Future<bool> toggleCourseSaved(CourseModel course) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_savedCoursesKey) ?? <String>[];
    final key = courseKey(course);
    final isSaved = saved.contains(key);
    if (isSaved) {
      saved.remove(key);
    } else {
      saved.add(key);
    }
    await prefs.setStringList(_savedCoursesKey, saved);
    return !isSaved;
  }

  Future<int> touchStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final previousKey = prefs.getString(_streakDateKey);
    var count = prefs.getInt(_streakCountKey) ?? 0;
    if (previousKey == todayKey) return count;
    final previous = previousKey == null
        ? null
        : DateTime.tryParse(previousKey);
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    count =
        previous != null &&
            previous.year == yesterday.year &&
            previous.month == yesterday.month &&
            previous.day == yesterday.day
        ? count + 1
        : 1;
    await prefs.setString(_streakDateKey, todayKey);
    await prefs.setInt(_streakCountKey, count);
    return count;
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

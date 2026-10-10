import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/blog_model.dart';
import '../../data/models/course_model.dart';

class LearningStateController extends GetxController {
  final completedLessons = <String>{}.obs;
  final savedCourses = <String>{}.obs;
  final savedBlogs = <String>{}.obs;
  final downloadedLessons = <String>{}.obs;
  final savedLessons = <String>{}.obs;
  final lessonNotes = <String, String>{}.obs;
  final resumeIndexes = <String, int>{}.obs;
  final isReady = false.obs;
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  static String courseKey(CourseModel course) =>
      'course:${course.id?.trim().isNotEmpty == true ? course.id : course.title ?? 'untitled'}';

  static String lessonKey(CourseModel course, int index) {
    final video = course.videos?[index];
    return '${courseKey(course)}:lesson:${video?.youtubeId ?? video?.title ?? index}';
  }

  String articleKey(BlogModel blog) => blog.id;

  bool isLessonCompleted(CourseModel course, int index) =>
      completedLessons.contains(lessonKey(course, index));

  int completedCount(CourseModel course) =>
      List.generate(course.videos?.length ?? 0, (index) => index)
          .where((index) => isLessonCompleted(course, index))
          .length;

  double progressFor(CourseModel course) {
    final total = course.videos?.length ?? 0;
    return total == 0 ? 0 : completedCount(course) / total;
  }

  bool isCourseSaved(CourseModel course) => savedCourses.contains(courseKey(course));
  bool isBlogSaved(BlogModel blog) => savedBlogs.contains(blog.id);

  bool isLessonDownloaded(CourseModel course, int index) =>
      downloadedLessons.contains(lessonKey(course, index));

  String videoLessonKey(String? courseTitle, VideoInfo video) =>
      'course:${courseTitle?.trim().isNotEmpty == true ? courseTitle!.trim() : 'untitled'}:lesson:${video.youtubeId ?? video.title ?? 'lesson'}';

  bool isVideoDownloaded(String? courseTitle, VideoInfo video) =>
      downloadedLessons.contains(videoLessonKey(courseTitle, video));

  bool isVideoSaved(String? courseTitle, VideoInfo video) =>
      savedLessons.contains(videoLessonKey(courseTitle, video));

  String noteForVideo(String? courseTitle, VideoInfo video) =>
      lessonNotes[videoLessonKey(courseTitle, video)] ?? '';

  Future<void> toggleVideoSaved(String? courseTitle, VideoInfo video) async {
    final key = videoLessonKey(courseTitle, video);
    savedLessons.contains(key) ? savedLessons.remove(key) : savedLessons.add(key);
    await _persist();
  }

  Future<void> saveVideoNote(
    String? courseTitle,
    VideoInfo video,
    String note,
  ) async {
    final key = videoLessonKey(courseTitle, video);
    final value = note.trim();
    if (value.isEmpty) {
      lessonNotes.remove(key);
    } else {
      lessonNotes[key] = value;
    }
    await _persist();
  }

  Future<void> toggleVideoDownload(String? courseTitle, VideoInfo video) async {
    final key = videoLessonKey(courseTitle, video);
    downloadedLessons.contains(key)
        ? downloadedLessons.remove(key)
        : downloadedLessons.add(key);
    await _persist();
  }

  int resumeIndex(CourseModel course) => resumeIndexes[courseKey(course)] ?? 0;

  Future<void> setResume(CourseModel course, int index) async {
    resumeIndexes[courseKey(course)] = index;
    await _persist();
  }

  Future<void> completeLesson(CourseModel course, int index) async {
    completedLessons.add(lessonKey(course, index));
    final total = course.videos?.length ?? 0;
    if (index + 1 < total) resumeIndexes[courseKey(course)] = index + 1;
    await _persist();
  }

  Future<void> toggleCourseSaved(CourseModel course) async {
    final key = courseKey(course);
    savedCourses.contains(key) ? savedCourses.remove(key) : savedCourses.add(key);
    await _persist();
  }

  Future<void> toggleBlogSaved(BlogModel blog) async {
    savedBlogs.contains(blog.id) ? savedBlogs.remove(blog.id) : savedBlogs.add(blog.id);
    await _persist();
  }

  Future<void> toggleLessonDownload(CourseModel course, int index) async {
    final key = lessonKey(course, index);
    downloadedLessons.contains(key)
        ? downloadedLessons.remove(key)
        : downloadedLessons.add(key);
    await _persist();
  }

  Future<void> clearDownloadedLessons() async {
    downloadedLessons.clear();
    await _persist();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    completedLessons.assignAll(_prefs?.getStringList('completed_lessons') ?? const []);
    savedCourses.assignAll(_prefs?.getStringList('saved_courses') ?? const []);
    savedBlogs.assignAll(_prefs?.getStringList('saved_blogs') ?? const []);
    downloadedLessons.assignAll(
      _prefs?.getStringList('downloaded_lessons') ?? const [],
    );
    savedLessons.assignAll(_prefs?.getStringList('saved_lessons') ?? const []);
    final rawNotes = _prefs?.getString('lesson_notes');
    if (rawNotes != null) {
      final decoded = jsonDecode(rawNotes);
      if (decoded is Map) {
        lessonNotes.assignAll(
          decoded.map((key, value) => MapEntry('$key', '$value')),
        );
      }
    }
    final rawResume = _prefs?.getStringList('resume_indexes') ?? const [];
    for (final entry in rawResume) {
      final split = entry.split('::');
      if (split.length == 2) {
        final index = int.tryParse(split[1]);
        if (index != null) resumeIndexes[split[0]] = index;
      }
    }
    isReady.value = true;
  }

  Future<void> _persist() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setStringList('completed_lessons', completedLessons.toList()),
      prefs.setStringList('saved_courses', savedCourses.toList()),
      prefs.setStringList('saved_blogs', savedBlogs.toList()),
      prefs.setStringList('downloaded_lessons', downloadedLessons.toList()),
      prefs.setStringList('saved_lessons', savedLessons.toList()),
      prefs.setString('lesson_notes', jsonEncode(lessonNotes)),
      prefs.setStringList(
        'resume_indexes',
        resumeIndexes.entries.map((entry) => '${entry.key}::${entry.value}').toList(),
      ),
    ]);
  }
}

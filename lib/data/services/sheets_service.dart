import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/blog_model.dart';
import '../models/course_model.dart';
import 'connectivity_service.dart';

class SheetsService {
  static const String _adminEmail = 'ak1500@gmail.com';
  static const Duration _cacheLifetime = Duration(minutes: 2);

  static List<BlogModel>? _blogsCache;
  static DateTime? _blogsCachedAt;
  static Future<List<BlogModel>>? _blogsRequest;
  static List<CourseModel>? _coursesCache;
  static DateTime? _coursesCachedAt;
  static Future<List<CourseModel>>? _coursesRequest;

  static bool get _online =>
      !Get.isRegistered<ConnectivityService>() ||
      Get.find<ConnectivityService>().isConnected.value;

  static bool _isFresh(DateTime? cachedAt) =>
      cachedAt != null && DateTime.now().difference(cachedAt) < _cacheLifetime;

  static Future<List<BlogModel>> fetchBlogs({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh(_blogsCachedAt) && _blogsCache != null) {
      return _blogsCache!;
    }
    if (!_online) return _blogsCache ?? const <BlogModel>[];
    if (_blogsRequest != null) return _blogsRequest!;

    final request = _fetchBlogs();
    _blogsRequest = request;
    try {
      final blogs = await request;
      _blogsCache = blogs;
      _blogsCachedAt = DateTime.now();
      return blogs;
    } finally {
      _blogsRequest = null;
    }
  }

  static Future<List<BlogModel>> _fetchBlogs() async {
    final response = await http
        .get(Uri.parse(blogsEndpoint))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Unable to load blogs (${response.statusCode}).');
    }
    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw const FormatException('Invalid blogs response.');
    }

    return decoded
        .whereType<Map>()
        .map((item) => BlogModel.fromJson(Map<String, dynamic>.from(item)))
        .where((blog) => blog.id.isNotEmpty || blog.title.isNotEmpty)
        .toList(growable: false);
  }

  static Future<List<CourseModel>> fetchCourses({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isFresh(_coursesCachedAt) && _coursesCache != null) {
      return _coursesCache!;
    }
    if (!_online) return _coursesCache ?? const <CourseModel>[];
    if (_coursesRequest != null) return _coursesRequest!;

    final request = _fetchCourses();
    _coursesRequest = request;
    try {
      final courses = await request;
      _coursesCache = courses;
      _coursesCachedAt = DateTime.now();
      return courses;
    } finally {
      _coursesRequest = null;
    }
  }

  static Future<List<CourseModel>> _fetchCourses() async {
    final response = await http
        .get(Uri.parse(coursesEndpoint))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Unable to load courses (${response.statusCode}).');
    }
    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw const FormatException('Invalid courses response.');
    }

    return decoded
        .whereType<Map>()
        .map((item) => CourseModel.fromJson(Map<String, dynamic>.from(item)))
        .where((course) => course.title?.isNotEmpty == true)
        .toList(growable: false);
  }

  // CRUD Operations for Blogs
  static Future<Map<String, dynamic>> createBlog(BlogModel blog) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(sheetsApiBase).replace(
        queryParameters: {
          'operation': 'create',
          'type': 'blogs',
          'admin': _adminEmail,
          'id': blog.id,
          'title': blog.title,
          'content': blog.content,
          'category': blog.category,
          'image_url': blog.imageUrl ?? '',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to create blog'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating blog: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateBlog(BlogModel blog) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(sheetsApiBase).replace(
        queryParameters: {
          'operation': 'update',
          'type': 'blogs',
          'admin': _adminEmail,
          'id': blog.id,
          'title': blog.title,
          'content': blog.content,
          'category': blog.category,
          'image_url': blog.imageUrl,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to update blog'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating blog: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteBlog(String blogId) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(sheetsApiBase).replace(
        queryParameters: {
          'operation': 'delete',
          'type': 'blogs',
          'admin': _adminEmail,
          'id': blogId,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to delete blog'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting blog: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // CRUD Operations for Courses
  static Future<Map<String, dynamic>> createCourseVideo({
    required String courseName,
    required String videoTitle,
    required String youtubeUrl,
    required String category,
  }) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(sheetsApiBase).replace(
        queryParameters: {
          'operation': 'create',
          'type': 'courses',
          'admin': _adminEmail,
          'course_name': courseName,
          'video_title': videoTitle,
          'youtube_url': youtubeUrl,
          'category': category,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to create course video'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating course video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateCourseVideo({
    required int row,
    String? courseName,
    String? videoTitle,
    String? youtubeUrl,
    String? category,
  }) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final queryParams = <String, String>{
        'operation': 'update',
        'type': 'courses',
        'admin': _adminEmail,
        'row': row.toString(),
      };

      if (courseName != null) queryParams['course_name'] = courseName;
      if (videoTitle != null) queryParams['video_title'] = videoTitle;
      if (youtubeUrl != null) queryParams['youtube_url'] = youtubeUrl;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse(
        sheetsApiBase,
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to update course video'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating course video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteCourseVideo(int row) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(sheetsApiBase).replace(
        queryParameters: {
          'operation': 'delete',
          'type': 'courses',
          'admin': _adminEmail,
          'row': row.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to delete course video'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting course video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get raw courses data for admin (with row numbers)
  static Future<List<Map<String, dynamic>>> fetchCoursesRaw() async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return [];
      }

      final uri = Uri.parse(sheetsApiBase).replace(
        queryParameters: {
          'operation': 'read',
          'type': 'courses_raw',
          'admin': _adminEmail,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching raw courses: $e');
      }
      return [];
    }
  }
}
